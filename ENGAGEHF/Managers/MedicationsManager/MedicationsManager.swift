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
            setupPreview()
            return
        }
        
        if FeatureFlags.setupTestMedications {
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
        
        guard let medicationRecsCollectionReference = try? Firestore.medicationRecsCollectionReference else {
            return
        }
        
        self.snapshotListener = medicationRecsCollectionReference
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


extension MedicationsManager {
    private func setupPreview() {
        self.medications = [
            MedicationDetails(
                id: "test1",
                title: "Lorem",
                subtitle: "Ipsum",
                description: "Description ",
                videoPath: "videoSections/1/videos/2",
                type: .targetDoseReached,
                dosageInformation: DosageInformation(
                    currentSchedule: [
                        DoseSchedule(frequency: 2, quantity: [25]),
                        DoseSchedule(frequency: 1, quantity: [15])
                    ],
                    minimumSchedule: [
                        DoseSchedule(frequency: 2, quantity: [5]),
                        DoseSchedule(frequency: 1, quantity: [2.5])
                    ],
                    targetSchedule: [
                        DoseSchedule(frequency: 2, quantity: [50]),
                        DoseSchedule(frequency: 1, quantity: [25])
                    ],
                    unit: "mg"
                )
            ),
            MedicationDetails(
                id: "test2",
                title: "Lozinopril",
                subtitle: "Beta Blocker",
                description: "Long description goes here",
                videoPath: "videoSections/1/videos/2",
                type: .improvementAvailable,
                dosageInformation: DosageInformation(
                    currentSchedule: [
                        DoseSchedule(frequency: 2, quantity: [25]),
                        DoseSchedule(frequency: 1, quantity: [15])
                    ],
                    minimumSchedule: [
                        DoseSchedule(frequency: 2, quantity: [5]),
                        DoseSchedule(frequency: 1, quantity: [2.5])
                    ],
                    targetSchedule: [
                        DoseSchedule(frequency: 2, quantity: [50]),
                        DoseSchedule(frequency: 1, quantity: [25])
                    ],
                    unit: "mg"
                )
            )
        ]
    }
}

#if DEBUG || TEST
extension MedicationsManager {
    func injectTestMedications() { // swiftlint:disable:this function_body_length
        self.medications = [
            // Single ingredient, single schedule, target dose reached
            MedicationDetails(
                id: UUID().uuidString,
                title: "Carvedilol",
                subtitle: "Beta Blocker",
                description: "Your target does has been reached.",
                videoPath: "videoSections/1/videos/2",
                type: .targetDoseReached,
                dosageInformation: DosageInformation(
                    currentSchedule: [DoseSchedule(frequency: 1, quantity: [200])],
                    minimumSchedule: [DoseSchedule(frequency: 1, quantity: [6.25])],
                    targetSchedule: [DoseSchedule(frequency: 1, quantity: [200])],
                    unit: "mg"
                )
            ),
            // Single ingredient, multiple schedules, personal target dose reached (middle range)
            MedicationDetails(
                id: UUID().uuidString,
                title: "Empagliflozin",
                subtitle: "SGLT2i",
                description: "You have reached your personal target dose.",
                videoPath: "videoSections/1/videos/2",
                type: .personalTargetDoseReached,
                dosageInformation: DosageInformation(
                    currentSchedule: [DoseSchedule(frequency: 1, quantity: [2.5]), DoseSchedule(frequency: 1, quantity: [5])],
                    minimumSchedule: [DoseSchedule(frequency: 1, quantity: [5])],
                    targetSchedule: [DoseSchedule(frequency: 1, quantity: [10])],
                    unit: "mg"
                )
            ),
            // Multi-ingredient, single schedule, at minimum dose
            MedicationDetails(
                id: UUID().uuidString,
                title: "Sacubitril-Valsartan",
                subtitle: "ARNI",
                description: "You are eligible for a new dosage.",
                videoPath: "videoSections/1/videos/2",
                type: .improvementAvailable,
                dosageInformation: DosageInformation(
                    currentSchedule: [DoseSchedule(frequency: 2, quantity: [24, 26])],
                    minimumSchedule: [DoseSchedule(frequency: 2, quantity: [24, 26])],
                    targetSchedule: [DoseSchedule(frequency: 2, quantity: [97, 103])],
                    unit: "mg"
                )
            ),
            // Single ingredient, below minimum dose, non-integer frequency
            MedicationDetails(
                id: UUID().uuidString,
                title: "Spironolactone",
                subtitle: "MRA",
                description: "More vitals data required for recommendations.",
                videoPath: nil,
                type: .morePatientObservationsRequired,
                dosageInformation: DosageInformation(
                    currentSchedule: [DoseSchedule(frequency: 1.5, quantity: [0])],
                    minimumSchedule: [DoseSchedule(frequency: 1.5, quantity: [12.5])],
                    targetSchedule: [DoseSchedule(frequency: 1.5, quantity: [25])],
                    unit: "mg"
                )
            ),
            // Single ingredient, single schedule, not started yet
            MedicationDetails(
                id: UUID().uuidString,
                title: "Bisoprolol",
                subtitle: "Beta Blocker",
                description: "Not started yet. No action required.",
                videoPath: "videoSections/1/videos/2",
                type: .notStarted,
                dosageInformation: DosageInformation(
                    currentSchedule: [],
                    minimumSchedule: [DoseSchedule(frequency: 1, quantity: [10])],
                    targetSchedule: [DoseSchedule(frequency: 1, quantity: [80])],
                    unit: "mg"
                )
            )
        ]
    }
}
#endif
