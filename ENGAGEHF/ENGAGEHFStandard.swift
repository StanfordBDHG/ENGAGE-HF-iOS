//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import FirebaseStorage
import HealthKitOnFHIR
import OSLog
import PDFKit
import Spezi
import SpeziAccount
import SpeziDevices
import SpeziFirebaseAccountStorage
import SpeziFirestore
import SpeziHealthKit
import SpeziOnboarding
import SpeziQuestionnaire
import SwiftUI


actor ENGAGEHFStandard: Standard, EnvironmentAccessible, OnboardingConstraint {
    @Application(\.logger) private var logger

    @Dependency(Account.self) private var account: Account?


    private var accountId: String {
        get async throws {
            guard let details = await account?.details else {
                throw FirebaseError.userNotAuthenticatedYet
            }
            return details.accountId
        }
    }


    func addMeasurement(samples: [HKSample]) async throws {
        guard !samples.isEmpty else {
            return
        }

        logger.debug("Saving \(samples.count) samples to firestore ...")
        let accountId = try await accountId

        do {
            let batch = Firestore.firestore().batch()
            for sample in samples {
                do {
                    guard let document = Firestore.collectionReference(for: accountId, type: sample.sampleType)?.document(sample.id.uuidString) else {
                        continue
                    }
                    try batch.setData(from: sample.resource, forDocument: document)
                } catch {
                    // either document retrieval or encoding failed, this should not stop other samples from getting saved
                    logger.debug("Failed to store sample in firebase, discarding: \(sample)")
                }
            }

            try await batch.commit()
        } catch {
            throw FirestoreError(error)
        }
    }
    
    
    func add(symptomScore: SymptomScore) async throws {
        let accountId = try await accountId
        do {
            try Firestore.symptomScoresCollectionReference(for: accountId).addDocument(from: symptomScore)
        } catch {
            throw FirestoreError(error)
        }
    }
    
    
    func add(message: Message) async throws {
        let accountId = try await accountId
        do {
            try Firestore.messagesCollectionReference(for: accountId).addDocument(from: message)
        } catch {
            throw FirestoreError(error)
        }
    }
    
    
    func add(response: ModelsR4.QuestionnaireResponse) async throws {
        let accountId = try await accountId
        do {
            let id = response.identifier?.value?.value?.string ?? UUID().uuidString
            try await Firestore.questionnaireResponseCollectionReference(for: accountId).document(id).setData(from: response)
        } catch {
            throw FirestoreError(error)
        }
    }
    
    /// Stores the given consent form in the user's document directory with a unique timestamped filename.
    ///
    /// - Parameter consent: The consent form's data to be stored as a `PDFDocument`.
    func store(consent: PDFDocument) async {
        guard !FeatureFlags.disableFirebase else {
            guard let basePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                logger.error("Could not create path for writing consent form to user document directory.")
                return
            }
            
            let filePath = basePath.appending(path: "consent.pdf")
            consent.write(to: filePath)
            
            return
        }
        
        do {
            guard let consentData = consent.dataRepresentation() else {
                logger.error("Could not store consent form.")
                return
            }
            
            let metadata = StorageMetadata()
            metadata.contentType = "application/pdf"

            let accountId = try await accountId
            _ = try await Storage.patientBucketReference(for: accountId).child("consent.pdf").putDataAsync(consentData, metadata: metadata)
        } catch {
            logger.error("Could not store consent form: \(error)")
        }
    }
}
