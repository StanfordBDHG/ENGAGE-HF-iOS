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
                collectionReference: userDocRef.collection("bodyWeightObservations"),
                storage: \.weightHistory,
                mapObservation: convertToHKQuantitySample
            )
        )
        
        // Heart Rate snapshot listener
        self.snapshotListeners.append(
            self.registerSnapshot(
                collectionReference: userDocRef.collection("heartRateObservations"),
                storage: \.heartRateHistory,
                mapObservation: convertToHKQuantitySample
            )
        )
        
        // Blood Pressure snapshot listener
        self.snapshotListeners.append(
            self.registerSnapshot(
                collectionReference: userDocRef.collection("bloodPressureObservations"),
                storage: \.bloodPressureHistory,
                mapObservation: convertToHKCorrelation
            )
        )
        
        // Symptom Survey Scores snapshot listener
        self.snapshotListeners.append(
            self.registerSnapshot(
                collectionReference: userDocRef.collection("kccqResults"),
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
        guard let observationType = observation.code.coding?.first?.code?.value?.string else {
            throw VitalsError.invalidConversion
        }
        
        let hkQuantity: HKQuantity
        let quantityType: HKQuantityType
        
        switch observationType {
        case "29463-7": // Weight
            hkQuantity = try self.getQuantity(observation: observation)
            quantityType = HKQuantityType(.bodyMass)
        case "8867-4": // Heart Rate
            hkQuantity = try self.getQuantity(observation: observation)
            quantityType = HKQuantityType(.heartRate)
        default:
            throw VitalsError.invalidObservationType
        }
        
        let effectiveDate = observation.getEffectiveDate()
        
        guard let effectiveDate else {
            throw VitalsError.invalidConversion
        }
        
        return HKQuantitySample(type: quantityType, quantity: hkQuantity, start: effectiveDate.start, end: effectiveDate.end)
    }
    
    private func convertToHKCorrelation(_ observation: R4Observation) throws -> HKCorrelation {
        // For now, only handle Blood Pressure
        guard let observationType = observation.code.coding?.first?.code?.value?.string,
              observationType == "85354-9" else {
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
        
        let systolicComponent = try self.getComponent(components, code: "8480-6")
        let diastolicComponent = try self.getComponent(components, code: "8462-4")
        
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
        
        return HKCorrelation(
            type: HKCorrelationType(.bloodPressure),
            start: effectiveDate.start,
            end: effectiveDate.end,
            objects: [systolicSample, diastolicSample]
        )
    }
    
    
    private func getComponent(_ components: [ObservationComponent], code: String) throws -> ObservationComponent {
        guard let component = components.first(
            where: {
                $0.code.coding?.contains(
                    where: {
                        $0.code?.value?.string == code
                    }
                ) ?? false
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
    /// Adds just over a month's worth of daily mock measurements to weight, heart rate, blood pressure, and symptoms histories
    /// 40 total measurements (1 each day) with random quantities
    private func setupPreview() {
        for dayOffset in 0..<40 {
            guard let startDate = Calendar.current.date(byAdding: .day, value: -dayOffset, to: .now) else {
                return
            }
            
            self.addMockBP(forDate: startDate)
            self.addMockHR(forDate: startDate)
            self.addMockWeight(forDate: startDate)
            
            // Only add mock symptoms once a week
            if dayOffset % 7 == 0 {
                self.addMockSymptoms(forDate: startDate)
            }
        }
    }
    
    private func addMockBP(forDate startDate: Date) {
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
        
        self.bloodPressureHistory.append(dummyBP)
    }
    
    private func addMockHR(forDate startDate: Date) {
        let dummyHR = HKQuantitySample(
            type: HKQuantityType(.heartRate),
            quantity: HKQuantity(unit: .count().unitDivided(by: .minute()), doubleValue: Double.random(in: 40...160)),
            start: startDate,
            end: startDate
        )
        
        self.heartRateHistory.append(dummyHR)
    }
    
    private func addMockWeight(forDate startDate: Date) {
        let dummyWeight = HKQuantitySample(
            type: HKQuantityType(.bodyMass),
            quantity: HKQuantity(unit: .pound(), doubleValue: Double.random(in: 80...180)),
            start: startDate,
            end: startDate
        )
        
        self.weightHistory.append(dummyWeight)
    }
    
    private func addMockSymptoms(forDate startDate: Date) {
        let dummySymptoms = SymptomScore(
            id: UUID().uuidString,
            date: startDate,
            overallScore: Double.random(in: 0...100),
            physicalLimitsScore: Double.random(in: 0...100),
            socialLimitsScore: Double.random(in: 0...100),
            qualityOfLifeScore: Double.random(in: 0...100),
            specificSymptomsScore: Double.random(in: 0...100),
            dizzinessScore: Double.random(in: 0...100)
        )
        
        self.symptomHistory.append(dummySymptoms)
    }
}
