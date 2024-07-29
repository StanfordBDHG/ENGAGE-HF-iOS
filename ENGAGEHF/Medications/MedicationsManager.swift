//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import OSLog
import Spezi
import SpeziFirebaseConfiguration


/// Medications Manager
///
/// Decodes the current user's medication recommendations from Firestore to an easily displayed internal representation
@Observable
class MedicationsManager: Module, EnvironmentAccessible {
    @ObservationIgnored @Dependency private var configureFirebaseApp: ConfigureFirebaseApp
    @ObservationIgnored @StandardActor private var standard: ENGAGEHFStandard
    
    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    private var snapshotListener: ListenerRegistration?
    private let logger = Logger(subsystem: "ENGAGEHF", category: "MedicationsManager")
    
    var medications: [MedicationDetails] = []
    
    
    func configure() {
        if ProcessInfo.processInfo.isPreviewSimulator {
            self.medications = [
                MedicationDetails(
                    id: "test1",
                    title: "Lorem",
                    subtitle: "Ipsum",
                    description: "Description ",
                    type: .targetDoseReached,
                    dosageInformation: DosageInformation(
                        currentSchedule: [DoseSchedule(timesDaily: 2, dose: 20.0)],
                        minimumDailyIntake: 15,
                        targetDailyIntake: 100,
                        unit: "mg"
                    )
                ),
                MedicationDetails(
                    id: "test2",
                    title: "Lozinopril",
                    subtitle: "Beta Blocker",
                    description: "Long description goes here",
                    type: .improvementAvailable,
                    dosageInformation: DosageInformation(
                        currentSchedule: [
                            DoseSchedule(timesDaily: 2, dose: 25),
                            DoseSchedule(timesDaily: 1, dose: 15)
                        ],
                        minimumDailyIntake: 10,
                        targetDailyIntake: 70,
                        unit: "mg"
                    )
                )
            ]
            return
        }
        
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.registerSnapshotListener(user: user)
        }
        
        self.registerSnapshotListener(user: Auth.auth().currentUser)
    }
    
    
    /// Call on sign-in. Registers a snapshot listener to the current user's medicationRecommendations collection and decodes the medications found there.
    private func registerSnapshotListener(user: User?) {
        logger.info("Initializing medications snapshot listener...")
        
        self.snapshotListener?.remove()
        guard let uid = user?.uid else {
            return
        }
        
        let firestore = Firestore.firestore()
        
        let patientDocumentReference = firestore
            .collection("users")
            .document(uid)
        
        self.snapshotListener = patientDocumentReference
            .collection("medicationRecommendations")
            .addSnapshotListener { querySnapshot, error in
                self.logger.debug("Fetching medications.")
                
                guard let recommendationRefs = querySnapshot?.documents else {
                    self.logger.error("Error fetching medication recommendation documents: \(error)")
                    return
                }
                
                self.medications = recommendationRefs.compactMap {
                    do {
                        return try $0.data(as: MedicationDetailsWrapper.self).medicationDetails
                    } catch {
                        self.logger.error("Failed to decode medication recommendation: \(error)")
                        return nil
                    }
                }
                
                self.logger.debug("Medications updated.")
            }
    }
}
