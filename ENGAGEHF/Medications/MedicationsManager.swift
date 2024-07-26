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
                        doses: [Dose(current: 67.3, minimum: 24.0, target: 100.0)],
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
                        doses: [Dose(current: 67.3, minimum: 24.0, target: 100.0)],
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
            .collection("patients")
            .document(uid)
        
        self.snapshotListener = patientDocumentReference
            .collection("medicationRecommendations")
            .addSnapshotListener { querySnapshot, error in
                guard let recommendationRefs = querySnapshot?.documents else {
                    self.logger.error("Error fetching medication recommendation documents: \(error)")
                    return
                }
                
                self.medications = recommendationRefs.compactMap {
                    do {
                        return try $0.data(as: MedicationDetails.self)
                    } catch {
                        self.logger.error("Error decoding medication details: \(error)")
                        return nil
                    }
                }
                
                self.logger.debug("Medications updated.")
            }
    }
}


//private extension MedicationsManager {
//    func getMedications(
//        recommendations recommendationRefs: [QueryDocumentSnapshot],
//        patientReference: FirebaseFirestore.DocumentReference,
//        using firestore: Firestore
//    ) async {
//        let medicationRecommendations: [MedicationRecommendationContext] = recommendationRefs.compactMap {
//            do {
//                return try $0.data(as: MedicationRecommendationContext.self)
//            } catch {
//                self.logger.error("Unable to decode medication recommendation: \(error)")
//                return nil
//            }
//        }
//        
//        let medicationRequests = await retrieveMedicationRequests(from: patientReference)
//        
//        var medications: [MedicationDetails] = []
//        for recommendation in medicationRecommendations {
//            do {
//                medications.append(try await recommendation.fetchAssociatedMedication(using: firestore, requests: medicationRequests))
//            } catch {
//                self.logger.error("Failed to fetch medication for \(recommendation.type.rawValue) recommendation: \(error)")
//                continue
//            }
//        }
//        
//        self.medications = medications
//        self.logger.debug("Medications successfully updated.")
//    }
//    
//    
//    /// Reduces number of firestore queries by collecting all documents from the patient's medicationRequests collection with one query.
//    /// Stores the results in a dictionary mapping reference path to medication request.
//    func retrieveMedicationRequests(from patientDocumentReference: DocumentReference) async -> [String: FHIRMedicationRequest] {
//        let medicationRequestsDocSnapshots: [QueryDocumentSnapshot]
//        do {
//            medicationRequestsDocSnapshots = try await patientDocumentReference
//                .collection("medicationRequests")
//                .getDocuments()
//                .documents
//        } catch {
//            self.logger.error("Failed to fetch documents from medication requests collection: \(error)")
//            return [:]
//        }
//        
//        // A dictionary mapping document reference path to the MedicationRequest found there
//        return Dictionary(grouping: medicationRequestsDocSnapshots, by: \.reference.path)
//            .compactMapValues {
//                do {
//                    // There should only be one MedicationRequest per reference path
//                    return try $0.first?.data(as: FHIRMedicationRequest.self)
//                } catch {
//                    self.logger.error("Failed to decode medication request \(error)")
//                    return nil
//                }
//            }
//    }
//}
