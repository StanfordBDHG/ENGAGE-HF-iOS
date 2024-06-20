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
class VitalsManager: Module, EnvironmentAccessible {
    @ObservationIgnored @StandardActor private var standard: ENGAGEHFStandard
    private let logger = Logger(subsystem: "ENGAGEHF", category: "VitalsManager")
    
    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    private var snapshotListener: ListenerRegistration?
    
    var heartRateHistory: [HKQuantitySample] = []
    var bloodPressureHistory: [HKCorrelation] = []
    var weightHistory: [HKQuantitySample] = []
    
    
    /// Call on initial configuration:
    /// - Add a snapshot listener to the three health data collections
    /// - Set the default units to the user's localized preferences
    func configure() {
        if ProcessInfo.processInfo.isPreviewSimulator {
            self.setupPreview()
            return
        }
        
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.registerSnapshotListener(user: user)
        }
        
        self.registerSnapshotListener(user: Auth.auth().currentUser)
    }
    
    func registerSnapshotListener(user: User?) {
        self.logger.debug("Initializing vitals snapshot listener...")
        
        // Remove previous snapshot listener for the user before creating new one
        snapshotListener?.remove()
        guard let uid = user?.uid else {
            self.logger.debug("No user signed in, skipping snapshot listener.")
            return
        }
        
        let firestore = Firestore.firestore()
        
        // Only store health data from the past month
        guard let thresholdDate = Calendar.current.date(byAdding: .month, value: -1, to: .now) else {
            logger.error("Unable to get threshold date for vitals query.")
            return
        }
        
        let thesholdTimeStamp = Timestamp(date: thresholdDate)
        
        // Set a snapshot listener on the query for valid notifications
        firestore
            .collection("users")
            .document(uid)
            .collection("")
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
