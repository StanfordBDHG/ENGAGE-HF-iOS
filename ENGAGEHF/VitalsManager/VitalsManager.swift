//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import Foundation
import HealthKit
import OSLog
import Spezi
import SpeziAccount
import SpeziFirestore
import SpeziFirebaseAccount


/// Vitals History Manager
///
/// Functionality:
/// - Maintain local, up-to-date arrays of the patients health data via Firestore SnapshotListeners
/// - Convert FHIR observations to HKQuantitySamples and HKCorrelations
@Observable
@MainActor
public class VitalsManager: Module, EnvironmentAccessible {
    enum VitalsError: Error {
        case invalidConversion
        case unknownUnit
        case invalidObservationType
        case missingField
    }
    
    @ObservationIgnored @StandardActor private var standard: ENGAGEHFStandard

    @ObservationIgnored @Dependency(Account.self) private var account: Account?
    @ObservationIgnored @Dependency(AccountNotifications.self) private var accountNotifications: AccountNotifications?
    @ObservationIgnored @Dependency(FirebaseAccountService.self) private var accountService: FirebaseAccountService?

    @Application(\.logger) @ObservationIgnored private var logger

    private var snapshotListeners: [ListenerRegistration] = []
    private var notificationsTask: Task<Void, Never>?

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

        if let accountNotifications {
            notificationsTask = Task.detached { @MainActor [weak self] in
                for await event in accountNotifications.events {
                    guard let self else {
                        return
                    }

                    switch event {
                    case let .associatedAccount(details):
                        updateSnapshotListener(for: details)

                        /// If testing, add mock measurements to the user's heart rate, blood pressure, weight, and symptoms histories
                        /// Called each time a new user signs in
                        if FeatureFlags.setupMockVitals {
                            do {
                                try await self.setupHeartHealthTesting(for: details)
                            } catch {
                                logger.error("Failed to setup Heart Health testing: \(error)")
                            }
                        }
                    case .disassociatingAccount:
                        updateSnapshotListener(for: nil)
                    default:
                        break
                    }
                }
            }
        }

        if let account {
            updateSnapshotListener(for: account.details)
        }
    }
    
    private func updateSnapshotListener(for details: AccountDetails?) {
        self.logger.debug("Initializing vitals snapshot listener...")
        
        // Remove previous snapshot listeners for the user before creating new ones
        for prevListener in self.snapshotListeners {
            prevListener.remove()
        }
        self.snapshotListeners = []

        // Only register snapshot listeners when a user is signed in
        guard let details else {
            self.logger.debug("No user signed in, skipping snapshot listener.")
            return
        }

        let bodyMassCollectionReference = Firestore.collectionReference(for: details.accountId, type: HKQuantityType(.bodyMass))
        let heartRateCollectionReference = Firestore.collectionReference(for: details.accountId, type: HKQuantityType(.heartRate))
        let bloodPressureCollectionReference = Firestore.collectionReference(for: details.accountId, type: HKCorrelationType(.bloodPressure))
        let symptomsCollectionReference = Firestore.symptomScoresCollectionReference(for: details.accountId)

        // Weight snapshot listener
        if let bodyMassCollectionReference {
            self.snapshotListeners.append(
                self.registerSnapshot(
                    collectionReference: bodyMassCollectionReference,
                    storage: \.weightHistory,
                    mapObservation: convertToHKQuantitySample
                )
            )
        }

        // Heart Rate snapshot listener
        if let heartRateCollectionReference {
            self.snapshotListeners.append(
                self.registerSnapshot(
                    collectionReference: heartRateCollectionReference,
                    storage: \.heartRateHistory,
                    mapObservation: convertToHKQuantitySample
                )
            )
        }

        // Blood Pressure snapshot listener
        if let bloodPressureCollectionReference {
            self.snapshotListeners.append(
                self.registerSnapshot(
                    collectionReference: bloodPressureCollectionReference,
                    storage: \.bloodPressureHistory,
                    mapObservation: convertToHKCorrelation
                )
            )
        }

        // Symptom Survey Scores snapshot listener
        self.snapshotListeners.append(
            self.registerSnapshot(
                collectionReference: symptomsCollectionReference,
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
    
    
    private func convertToHKQuantitySample(_ observation: FHIRObservation) throws -> HKQuantitySample {
        let hkQuantity: HKQuantity
        let quantityType: HKQuantityType
        
        if observation.code.containsCoding(code: "29463-7", system: FHIRSystem.loinc) {
            // Weight
            hkQuantity = try self.getQuantity(observation: observation)
            quantityType = HKQuantityType(.bodyMass)
        } else if observation.code.containsCoding(code: "8867-4", system: FHIRSystem.loinc) {
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
    
    private func convertToHKCorrelation(_ observation: FHIRObservation) throws -> HKCorrelation {
        // For now, only handle Blood Pressure
        guard observation.code.containsCoding(code: "85354-9", system: FHIRSystem.loinc) else {
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
        
        let systolicComponent = try self.getComponent(components, code: "8480-6", system: FHIRSystem.loinc)
        let diastolicComponent = try self.getComponent(components, code: "8462-4", system: FHIRSystem.loinc)
        
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
    
    
    private func getComponent(_ components: [FHIRObservationComponent], code: String, system: URL) throws -> FHIRObservationComponent {
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

    deinit {
        _notificationsTask?.cancel()
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
            symptomFrequencyScore: Double.random(in: 0...100),
            dizzinessScore: Double.random(in: 0...5)
        )
        
        return dummySymptoms
    }
}


extension VitalsManager {
    private func setupHeartHealthTesting(for details: AccountDetails) async throws {
        // Make sure the user has not already had mock data initialized
        for collectionReference in GraphSelection.allCases.compactMap({ $0.collectionReference(for: details.accountId) }) {
            // Not recommended to delete collections from the client, so for now just skipping if the collection already exists
            guard try await collectionReference.getDocuments().documents.isEmpty else {
                // Collection exists and is not empty, so skip
                self.logger.debug("\(collectionReference) already exist, skipping user.")
                return
            }
        }
        
        for count in 0..<50 {
            guard let date = Calendar.current.date(byAdding: .day, value: -Int.random(in: 0..<100), to: .now) else {
                self.logger.error("Unable to create date for Heart Health testing setup.")
                return
            }
            
            try await self.standard.addMeasurement(
                samples: [
                    self.getRandomWeight(forDate: date),
                    self.getRandomHeartRate(forDate: date),
                    self.getRandomBloodPressure(forDate: date)
                ]
            )
            
            if count.isMultiple(of: 10) {
                try await self.standard.add(symptomScore: self.getRandomSymptoms(forDate: date))
            }
        }
    }
}


extension VitalsManager {
    /// Call on deletion of a measurement -- removes the measurement with the given document id from the user's collection 
    func deleteMeasurement(id: String?, graphSelection: GraphSelection) async throws {
        guard let id, let account, let details = account.details,
              let collectionReference = graphSelection.collectionReference(for: details.accountId) else {
            self.logger.warning("Attempting to delete \(graphSelection) measurement. Failed!")
            return
        }
        
        do {
            try await collectionReference.document(id).delete()
            self.logger.debug("Successfully deleted measurement (\(id)) from \(collectionReference)")
        } catch {
            self.logger.error("Error deleting measurement (\(id)) from \(collectionReference): \(error)")
            throw FirestoreError(error)
        }
    }
}
