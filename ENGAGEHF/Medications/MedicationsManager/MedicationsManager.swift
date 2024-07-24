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
    
    var medications: [Medication] = []
    
    
    func configure() {
        if ProcessInfo.processInfo.isPreviewSimulator {
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
        
        let patientDocumentReference = Firestore.firestore()
            .collection("patients")
            .document(uid)
        
        self.snapshotListener = patientDocumentReference
            .collection("medicationRecommendations")
            .addSnapshotListener { querySnapshot, error in
                guard let documentRefs = querySnapshot?.documents else {
                    self.logger.error("Error fetching medication recommendation documents: \(error)")
                    return
                }
                
                Task {
                    self.medications = await self.parseMedications(from: documentRefs, patientDocRef: patientDocumentReference)
                    self.logger.debug("Medications updated.")
                }
            }
    }
    
    
    private func parseMedications(
        from documentRefs: [QueryDocumentSnapshot],
        patientDocRef patientDocumentReference: DocumentReference
    ) async -> [Medication] {
        let medicationRecommendations: [MedicationRecommendation] = documentRefs.compactMap {
            do {
                return try $0.data(as: MedicationRecommendation.self)
            } catch {
                self.logger.error("Unable to decode medication recommendation: \(error)")
                return nil
            }
        }
        
        var medications: [Medication] = []
        for recommendation in medicationRecommendations {
            do {
                medications.append(try await recommendation.fetchAssociatedMedication(from: patientDocumentReference))
            } catch {
                self.logger.error("Failed to fetch medication for \(recommendation.type.rawValue) recommendation: \(error)")
                continue
            }
        }
        
        return medications
    }
}
