//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import HealthKit
import struct ModelsR4.DateTime
import class ModelsR4.ObservationComponent
import OSLog
import Spezi
import SpeziFirebaseConfiguration


/// Vitals History Manager
///
/// Functionality:
/// - Maintain local, up-to-date arrays of the patients health data via Firestore SnapshotListeners
/// - Convert FHIR observations to HKQuantitySamples and HKCorrelations
@Observable
public class VitalsManager: Module, EnvironmentAccessible {
    enum VitalsError: Error {
        case invalidConversion
        case unknownUnit
        case invalidObservationType
        case missingField
    }
    
    
    @ObservationIgnored @Dependency private var configureFirebaseApp: ConfigureFirebaseApp
    @ObservationIgnored @StandardActor private var standard: ENGAGEHFStandard
    private let logger = Logger(subsystem: "ENGAGEHF", category: "VitalsManager")
    
    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    private var snapshotListeners: [ListenerRegistration] = []
    
    public var heartRateHistory: [HKQuantitySample] = []
    public var bloodPressureHistory: [HKCorrelation] = []
    public var weightHistory: [HKQuantitySample] = []
    
    public var symptomHistory: [SymptomScore] = []
    
    
    public var latestHeartRate: HKQuantitySample? {
        heartRateHistory.max { $0.startDate < $1.startDate }
    }
    public var latestBloodPressure: HKCorrelation? {
        bloodPressureHistory.max { $0.startDate < $1.startDate }
    }
    public var latestWeight: HKQuantitySample? {
        weightHistory.max { $0.startDate < $1.startDate }
    }
    
    
    /// Call on initial configuration:
    /// - Add a snapshot listener to the three health data collections
    public func configure() {
        if ProcessInfo.processInfo.isPreviewSimulator {
            self.setupPreview()
            return
        }
        
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.registerSnapshotListeners(user: user)
            
            /// If testing, add mock measurements to the user's heart rate, blood pressure, weight, and symptoms histories
            /// Called each time a new user signs in
            if FeatureFlags.setupTestEnvironment, let user {
                Task {
                    try await self?.setupHeartHealthTesting(user: user)
                }
            }
        }
        
        self.registerSnapshotListeners(user: Auth.auth().currentUser)
    }
    
    private func registerSnapshotListeners(user: User?) {
        self.logger.debug("Initializing vitals snapshot listener...")
        
        // Remove previous snapshot listeners for the user before creating new ones
        for prevListener in self.snapshotListeners {
            prevListener.remove()
        }
        self.snapshotListeners = []
        
        // Only register snapshot listeners when a user is signed in
        guard let uid = user?.uid else {
            self.logger.debug("No user signed in, skipping snapshot listener.")
            return
        }
        
        let firestore = Firestore.firestore()
        let userDocRef = firestore.collection("users").document(uid)
        
        // Weight snapshot listener
        self.snapshotListeners.append(
            self.registerSnapshot(
                collectionReference: userDocRef.collection(CollectionID.bodyWeightObservations.rawValue),
                storage: \.weightHistory,
                mapObservation: convertToHKQuantitySample
            )
        )
        
        // Heart Rate snapshot listener
        self.snapshotListeners.append(
            self.registerSnapshot(
                collectionReference: userDocRef.collection(CollectionID.heartRateObservations.rawValue),
                storage: \.heartRateHistory,
                mapObservation: convertToHKQuantitySample
            )
        )
        
        // Blood Pressure snapshot listener
        self.snapshotListeners.append(
            self.registerSnapshot(
                collectionReference: userDocRef.collection(CollectionID.bloodPressureObservations.rawValue),
                storage: \.bloodPressureHistory,
                mapObservation: convertToHKCorrelation
            )
        )
        
        // Symptom Survey Scores snapshot listener
        self.snapshotListeners.append(
            self.registerSnapshot(
                collectionReference: userDocRef.collection(CollectionID.kccqResults.rawValue),
                storage: \.symptomHistory,
                mapObservation: { $0 }
            )
        )
    }
    
    private func registerSnapshot<T, V: Decodable>(
        collectionReference: CollectionReference,
        storage: ReferenceWritableKeyPath<VitalsManager, [T]>,
        mapObservation: @escaping (V) throws -> T
    ) -> ListenerRegistration {
        // Return a listener for the given collection
        collectionReference
            .addSnapshotListener { querySnapshot, error in
                self.logger.debug("Fetching most recent \(collectionReference.collectionID) history...")
                guard let documentRefs = querySnapshot?.documents else {
                    self.logger.error("Error fetching \(collectionReference.collectionID) observations: \(error)")
                    return
                }
                
                self[keyPath: storage] = documentRefs.compactMap {
                    do {
                        return try mapObservation($0.data(as: V.self))
                    } catch {
                        self.logger.error("Error saving \(collectionReference.collectionID) history: \(error)")
                        return nil
                    }
                }
                
                self.logger.debug("\(collectionReference.collectionID) history updated successfully.")
            }
    }
    
    
    private func convertToHKQuantitySample(_ observation: R4Observation) throws -> HKQuantitySample {
        let hkQuantity: HKQuantity
        let quantityType: HKQuantityType
        
        if observation.code.containsCoding(code: "29463-7", system: FHIRSystem.loinc.url) {
            // Weight
            hkQuantity = try self.getQuantity(observation: observation)
            quantityType = HKQuantityType(.bodyMass)
        } else if observation.code.containsCoding(code: "8867-4", system: FHIRSystem.loinc.url) {
            // Heart Rate
            hkQuantity = try self.getQuantity(observation: observation)
            quantityType = HKQuantityType(.heartRate)
        } else {
            throw VitalsError.invalidObservationType
        }
        
        let effectiveDate = observation.getEffectiveDate()
        
        guard let effectiveDate else {
            throw VitalsError.invalidConversion
        }
        
        guard let identifier = observation.id?.value?.string else {
            throw VitalsError.missingField
        }
        
        return HKQuantitySample(
            type: quantityType,
            quantity: hkQuantity,
            start: effectiveDate.start,
            end: effectiveDate.end,
            metadata: [HKMetadataKeyExternalUUID: identifier]
        )
    }
    
    private func convertToHKCorrelation(_ observation: R4Observation) throws -> HKCorrelation {
        // For now, only handle Blood Pressure
        guard observation.code.containsCoding(code: "85354-9", system: FHIRSystem.loinc.url) else {
            throw VitalsError.invalidObservationType
        }
        
        let effectiveDate = observation.getEffectiveDate()
        
        guard let effectiveDate else {
            throw VitalsError.invalidConversion
        }
        
        // Index into the components of the observation for systolic and diastolic measurements
        guard let components = observation.component else {
            throw VitalsError.missingField
        }
        
        let systolicComponent = try self.getComponent(components, code: "8480-6", system: FHIRSystem.loinc.url)
        let diastolicComponent = try self.getComponent(components, code: "8462-4", system: FHIRSystem.loinc.url)
        
        let systolicQuantity = try self.getQuantity(observation: systolicComponent)
        let diastolicQuantity = try self.getQuantity(observation: diastolicComponent)
        
        let systolicSample = HKQuantitySample(
            type: HKQuantityType(.bloodPressureSystolic),
            quantity: systolicQuantity,
            start: effectiveDate.start,
            end: effectiveDate.end
        )
        let diastolicSample = HKQuantitySample(
            type: HKQuantityType(.bloodPressureDiastolic),
            quantity: diastolicQuantity,
            start: effectiveDate.start,
            end: effectiveDate.end
        )
        
        guard let identifier = observation.id?.value?.string else {
            throw VitalsError.missingField
        }
        
        return HKCorrelation(
            type: HKCorrelationType(.bloodPressure),
            start: effectiveDate.start,
            end: effectiveDate.end,
            objects: [systolicSample, diastolicSample],
            metadata: [HKMetadataKeyExternalUUID: identifier]
        )
    }
    
    
    private func getComponent(_ components: [ObservationComponent], code: String, system: URL) throws -> ObservationComponent {
        guard let component = components.first(
            where: {
                $0.code.containsCoding(code: code, system: system)
            }
        ) else {
            throw VitalsError.missingField
        }
        
        return component
    }
    
    private func getQuantity(observation: ObservationValueProtocol) throws -> HKQuantity {
        guard case let .quantity(fhirQuantity) = observation.observationValue?.type else {
            throw VitalsError.invalidConversion
        }
        
        guard let sampleQuantity = fhirQuantity.value?.value?.decimal else {
            throw VitalsError.invalidConversion
        }
        
        let quantity = sampleQuantity.doubleValue
        
        let units: HKUnit
        switch fhirQuantity.unit?.value?.string {
        case "lbs":
            units = HKUnit.pound()
        case "kg":
            units = HKUnit.gramUnit(with: .kilo)
        case "beats/minute":
            units = .count().unitDivided(by: .minute())
        case "mmHg":
            units = HKUnit.millimeterOfMercury()
        default:
            throw VitalsError.unknownUnit
        }
        
        return HKQuantity(unit: units, doubleValue: quantity)
    }
}


extension VitalsManager {
    /// Adds just over a month's worth of daily mock measurements to local weight, heart rate, blood pressure, and symptoms histories
    /// 40 total measurements (1 each day) with random quantities
    private func setupPreview() {
        for count in 0..<40 {
            guard let startDate = Calendar.current.date(byAdding: .day, value: -Int.random(in: 0..<40), to: .now) else {
                return
            }
            
            self.bloodPressureHistory.append(self.getRandomBloodPressure(forDate: startDate))
            self.heartRateHistory.append(self.getRandomHeartRate(forDate: startDate))
            self.weightHistory.append(self.getRandomWeight(forDate: startDate))
            
            // Only add mock symptoms once a week
            if count.isMultiple(of: 7) {
                self.symptomHistory.append(self.getRandomSymptoms(forDate: startDate))
            }
        }
    }
    
    private func getRandomBloodPressure(forDate startDate: Date) -> HKCorrelation {
        let diastolic = HKQuantity(unit: .millimeterOfMercury(), doubleValue: Double.random(in: 40...90))
        let systolic = HKQuantity(unit: .millimeterOfMercury(), doubleValue: Double.random(in: 90...140))
        
        let dummyDiastolic = HKQuantitySample(
            type: HKQuantityType(.bloodPressureDiastolic),
            quantity: diastolic,
            start: startDate,
            end: startDate
        )
        let dummySystolic = HKQuantitySample(
            type: HKQuantityType(.bloodPressureSystolic),
            quantity: systolic,
            start: startDate,
            end: startDate
        )
        let dummyBP = HKCorrelation(
            type: HKCorrelationType(.bloodPressure),
            start: startDate,
            end: startDate,
            objects: [dummyDiastolic, dummySystolic]
        )
        
        return dummyBP
    }
    
    private func getRandomHeartRate(forDate startDate: Date) -> HKQuantitySample {
        let dummyHR = HKQuantitySample(
            type: HKQuantityType(.heartRate),
            quantity: HKQuantity(unit: .count().unitDivided(by: .minute()), doubleValue: Double.random(in: 40...160)),
            start: startDate,
            end: startDate
        )
        
        return dummyHR
    }
    
    private func getRandomWeight(forDate startDate: Date) -> HKQuantitySample {
        let dummyWeight = HKQuantitySample(
            type: HKQuantityType(.bodyMass),
            quantity: HKQuantity(unit: .pound(), doubleValue: Double.random(in: 80...180)),
            start: startDate,
            end: startDate
        )
        
        return dummyWeight
    }
    
    private func getRandomSymptoms(forDate startDate: Date) -> SymptomScore {
        let dummySymptoms = SymptomScore(
            id: ProcessInfo.processInfo.isPreviewSimulator ? UUID().uuidString : nil,
            date: startDate,
            overallScore: Double.random(in: 0...100),
            physicalLimitsScore: Double.random(in: 0...100),
            socialLimitsScore: Double.random(in: 0...100),
            qualityOfLifeScore: Double.random(in: 0...100),
            specificSymptomsScore: Double.random(in: 0...100),
            dizzinessScore: Double.random(in: 0...100)
        )
        
        return dummySymptoms
    }
}


extension VitalsManager {
    private func setupHeartHealthTesting(user: User) async throws {
        let firestore = Firestore.firestore()
        let userDocRef = firestore
            .collection("users")
            .document(user.uid)
        
        
        // Make sure the user has not already had mock data initialized
        for collectionID in CollectionID.allCases {
            let querySnapshot = try await userDocRef.collection(collectionID.rawValue).getDocuments()
            
            // Not recommended to delete collections from the client, so for now just skipping if the collection already exists
            guard querySnapshot.documents.isEmpty else {
                // Collection exists and is not empty, so skip
                self.logger.debug("\(collectionID.rawValue) already exist, skipping user.")
                return
            }
        }
        
        for _ in 0..<3 {
            guard let date = Calendar.current.date(byAdding: .day, value: -Int.random(in: 0..<40), to: .now) else {
                self.logger.error("Unable to create date for Heart Health testing setup.")
                return
            }
            
            await self.standard.add(sample: self.getRandomWeight(forDate: date))
            await self.standard.add(sample: self.getRandomHeartRate(forDate: date))
            await self.standard.add(sample: self.getRandomBloodPressure(forDate: date))
            await self.standard.add(symptomScore: self.getRandomSymptoms(forDate: date))
        }
    }
}


extension VitalsManager {
    /// A function for structuring the data stored in the VitalsManager in a format suitable for displaying in a chart.
    /// Supports multiple quantities per datapoint (such as Systolic and Diastolic quantities for Blood Pressure).
    /// For data with multiple quantites, each quantity must be in the same unit.
    /// Datapoints that fall on the same interval are averaged.
    ///
    /// - Parameters:
    ///   - dateRange: The time interval in which to display the data
    ///   - resolution: The component of the date that will be used for the x-axis
    ///   - storage: The KeyPath to the data that will be displayed
    ///   - unit: The unit or sub-type of the data.
    ///         For HKSamples, must be one of the strings described in https://developer.apple.com/documentation/healthkit/hkunit/1615733-init
    ///         For SymptomScores, must be one of the raw values of the enum as defined in the `SymptomType` enum
    public func collate<T: Graphable>(
        dateRange: ClosedRange<Date>,
        resolution: Calendar.Component,
        storage: KeyPath<VitalsManager, [T]>,
        unit: String
    ) -> [(date: Date, averageValues: [Double])] {
        var dataBins: [Date: [[Double]]] = [:]
        let calendar = Calendar.current
        
        /// Filter for the datapoints within the specified date range
        let filteredData = self[keyPath: storage].filter { dateRange.contains($0.date) }
        
        
        /// Bin the data according to the time interval in dateRange their resolution component falls into
        for dataPoint in filteredData {
            guard let binStartDate = calendar.dateInterval(of: resolution, for: dataPoint.date)?.start else {
                continue
            }
            
            if !dataBins.contains(where: { $0.key == binStartDate }) {
                dataBins[binStartDate] = []
            }
            
            let values = dataPoint.getDoubleValues(for: unit)
            dataBins[binStartDate]?.append(values)
        }
        
        /// Take the average across each quantity for each time interval
        var result: [(date: Date, averageValues: [Double])] = []
        
        for (date, values) in dataBins {
            let averages: [Double] = values.compactMap { quantitySamples in
                guard !quantitySamples.isEmpty else {
                    return nil
                }
                
                return quantitySamples.reduce(0, +) / Double(quantitySamples.count)
            }
            
            result.append((date, averages))
        }

        return result
    }
}


extension VitalsManager {
    /// Call on deletion of a measurement -- removes the measurement with the given document id from the user's collection 
    func deleteMeasurement(id: String?, collectionID: CollectionID) async throws {
        guard let id else {
            self.logger.error("Attempting to delete nonexistant measurement from \(collectionID.rawValue).")
            return
        }
        
        self.logger.debug("Attempting to delete measurement (\(id)) from \(collectionID.rawValue)")
        let firestore = Firestore.firestore()
        
        guard let user = Auth.auth().currentUser else {
            logger.error("Unable to delete measurement: User not authenticated")
            return
        }
        
        let collectionRef = firestore
            .collection("users")
            .document(user.uid)
            .collection(collectionID.rawValue)
        
        do {
            try await collectionRef.document(id).delete()
            self.logger.debug("Successfully deleted measurement (\(id)) from \(collectionID.rawValue)")
        } catch {
            self.logger.error("Error deleting measurement (\(id)) from \(collectionID.rawValue): \(error)")
            throw error
        }
    }
} // swiftlint:disable:this file_length
