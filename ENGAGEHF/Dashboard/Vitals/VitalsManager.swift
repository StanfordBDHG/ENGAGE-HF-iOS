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
/// - Maintain local, up-to-date arrays of the patients health data
/// - Convert FHIR quantities to HK Samples
/// - Manage units of the stored quantities, defaulting to the user's phone settings
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
    private var snapshotListener: ListenerRegistration?
    
    // TODO: Localize the units based on either locale or user preferences in the phone settings
    public var heartRateHistory: [HKQuantitySample] = []
    public var bloodPressureHistory: [HKCorrelation] = []
    public var weightHistory: [HKQuantitySample] = []
    
    
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
    /// - Set the default units to the user's localized preferences
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
        
        // Remove previous snapshot listener for the user before creating new one
        snapshotListener?.remove()
        guard let uid = user?.uid else {
            self.logger.debug("No user signed in, skipping snapshot listener.")
            return
        }
        
        let firestore = Firestore.firestore()
        let userDocRef = firestore.collection("users").document(uid)
        
        self.registerWeightSnapshot(userDocRef: userDocRef)
        self.registerHeartRateSnapshot(userDocRef: userDocRef)
        self.registerBloodPressureSnapshot(userDocRef: userDocRef)
    }
    
    private func registerWeightSnapshot(userDocRef: DocumentReference) {
        // Listen for Weight measurements
        userDocRef
            .collection("bodyWeightObservations")
            .addSnapshotListener { querySnapshot, error in
                self.logger.debug("Fetching most recent Weight history...")
                guard let documentRefs = querySnapshot?.documents else {
                    self.logger.error("Error fetching Weight observations: \(error)")
                    return
                }
                
                self.weightHistory = documentRefs.compactMap {
                    do {
                        return try self.convertToHKQuantitySample($0.data(as: R4Observation.self))
                    } catch {
                        self.logger.error("Error saving Weight history: \(error)")
                        return nil
                    }
                }
                
                self.logger.debug("Weight history updated successfully.")
            }
    }
    
    private func registerHeartRateSnapshot(userDocRef: DocumentReference) {
        // Listen for Heart Rate measurements
        userDocRef
            .collection("heartRateObservations")
            .addSnapshotListener { querySnapshot, error in
                self.logger.debug("Fetching most recent Heart Rate history...")
                guard let documentRefs = querySnapshot?.documents else {
                    self.logger.error("Error fetching Heart Rate observations: \(error)")
                    return
                }
                
                self.heartRateHistory = documentRefs.compactMap {
                    do {
                        return try self.convertToHKQuantitySample($0.data(as: R4Observation.self))
                    } catch {
                        self.logger.error("Error saving Heart Rate history: \(error)")
                        return nil
                    }
                }
                
                self.logger.debug("Heart Rate history updated successfully.")
            }
    }
    
    private func registerBloodPressureSnapshot(userDocRef: DocumentReference) {
        // Listen for Blood Pressure measurements
        userDocRef
            .collection("bloodPressureObservations")
            .addSnapshotListener { querySnapshot, error in
                self.logger.debug("Fetching most recent Blood Pressure history...")
                guard let documentRefs = querySnapshot?.documents else {
                    self.logger.error("Error fetching Blood Pressure observations: \(error)")
                    return
                }
                
                self.bloodPressureHistory = documentRefs.compactMap {
                    do {
                        return try self.convertToHKCorrelation($0.data(as: R4Observation.self))
                    } catch {
                        self.logger.error("Error saving Blood Pressure history: \(error)")
                        return nil
                    }
                }
                
                self.logger.debug("Blood Pressure history updated successfully.")
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
        
        let (startDate, endDate) = observation.getEffectiveDate()
        
        guard let startDate, let endDate else {
            throw VitalsError.invalidConversion
        }
        
        return HKQuantitySample(type: quantityType, quantity: hkQuantity, start: startDate, end: endDate)
    }
    
    private func convertToHKCorrelation(_ observation: R4Observation) throws -> HKCorrelation {
        // For now, only handle Blood Pressure
        guard let observationType = observation.code.coding?.first?.code?.value?.string,
              observationType == "85354-9" else {
            throw VitalsError.invalidObservationType
        }
        
        let (startDate, endDate) = observation.getEffectiveDate()
        
        guard let startDate, let endDate else {
            throw VitalsError.invalidConversion
        }
        
        // Index into the components of the observation for systolic and diastolic measurements
        guard let components = observation.component else {
            throw VitalsError.missingField
        }
        
        let systolicComponent = try self.getComponent(components, code: "8480-6")
        let diastolicComponent = try self.getComponent(components, code: "8462-4")
        
        let systolicQuantity = try self.getQuantity(component: systolicComponent)
        let diastolicQuantity = try self.getQuantity(component: diastolicComponent)
        
        let systolicSample = HKQuantitySample(
            type: HKQuantityType(.bloodPressureSystolic),
            quantity: systolicQuantity,
            start: startDate,
            end: endDate
        )
        let diastolicSample = HKQuantitySample(
            type: HKQuantityType(.bloodPressureDiastolic),
            quantity: diastolicQuantity,
            start: startDate,
            end: endDate
        )
        
        return HKCorrelation(
            type: HKCorrelationType(.bloodPressure),
            start: startDate,
            end: endDate,
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
    
    // TODO: Combine the two versions of this into a generic function?
    private func getQuantity(observation: R4Observation) throws -> HKQuantity {
        guard case let .quantity(fhirQuantity) = observation.value else {
            throw VitalsError.invalidConversion
        }
        
        guard let sampleQuantity = fhirQuantity.value?.value?.decimal else {
            throw VitalsError.invalidConversion
        }
        
        let quantity = NSDecimalNumber(decimal: sampleQuantity).doubleValue
        
        let units: HKUnit
        switch fhirQuantity.unit?.value?.string {
        case "lbs":
            units = HKUnit.pound()
        case "kg":
            units = HKUnit.gramUnit(with: .kilo)
        case "beats/minute":
            units = .count().unitDivided(by: .minute())
        default:
            throw VitalsError.unknownUnit
        }
        
        return HKQuantity(unit: units, doubleValue: quantity)
    }
    
    private func getQuantity(component: ObservationComponent) throws -> HKQuantity {
        guard case let .quantity(fhirQuantity) = component.value else {
            throw VitalsError.invalidConversion
        }
        
        guard let sampleQuantity = fhirQuantity.value?.value?.decimal else {
            throw VitalsError.invalidConversion
        }
        
        let quantity = NSDecimalNumber(decimal: sampleQuantity).doubleValue
        
        let units: HKUnit
        switch fhirQuantity.unit?.value?.string {
        case "mmHg":
            units = HKUnit.millimeterOfMercury()
        case "kPa":
            // TODO: Make sure this string is a valid representation of the unit
            units = HKUnit.pascalUnit(with: .kilo)
        default:
            throw VitalsError.unknownUnit
        }
        
        return HKQuantity(unit: units, doubleValue: quantity)
    }
}


extension VitalsManager {
    private func setupPreview() {
        let dummyHR = HKQuantitySample(
            type: HKQuantityType(.heartRate),
            quantity: HKQuantity(unit: .count().unitDivided(by: .minute()), doubleValue: Double(60)),
            start: .now,
            end: .now
        )
        
        let diastolic = HKQuantity(unit: .millimeterOfMercury(), doubleValue: Double(120))
        let systolic = HKQuantity(unit: .millimeterOfMercury(), doubleValue: Double(70))
        
        let dummyDiastolic = HKQuantitySample(
            type: HKQuantityType(.bloodPressureDiastolic),
            quantity: diastolic, 
            start: .now,
            end: .now
        )
        let dummySystolic = HKQuantitySample(
            type: HKQuantityType(.bloodPressureSystolic),
            quantity: systolic,
            start: .now,
            end: .now
        )
        let dummyBP = HKCorrelation(
            type: HKCorrelationType(.bloodPressure),
            start: .now,
            end: .now,
            objects: [dummyDiastolic, dummySystolic]
        )
        
        let dummyWeight = HKQuantitySample(
            type: HKQuantityType(.bodyMass),
            quantity: HKQuantity(unit: .gramUnit(with: .kilo), doubleValue: Double(70)),
            start: .now,
            end: .now
        )
        
        self.heartRateHistory.append(dummyHR)
        self.bloodPressureHistory.append(dummyBP)
        self.weightHistory.append(dummyWeight)
    }
}
