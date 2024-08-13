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


actor ENGAGEHFStandard: Standard,
                        EnvironmentAccessible,
                        OnboardingConstraint,
                        AccountStorageConstraint,
                        AccountNotifyConstraint {
    @Dependency var accountStorage: FirestoreAccountStorage?
    @AccountReference var account: Account

    private let logger = Logger(subsystem: "ENGAGEHF", category: "Standard")
    

    func addMeasurement(samples: [HKSample]) async throws {
        guard !samples.isEmpty else {
            return
        }

        logger.debug("Saving \(samples.count) samples to firestore ...")

        do {
            let batch = Firestore.firestore().batch()
            for sample in samples {
                do {
                    guard let document = try Firestore.collectionReference(for: sample.sampleType)?.document(sample.id.uuidString) else {
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
        do {
            try Firestore.symptomScoresCollectionReference.addDocument(from: symptomScore)
        } catch {
            throw FirestoreError(error)
        }
    }
    
    
    func add(message: Message) async throws {
        do {
            try Firestore.messagesCollectionReference.addDocument(from: message)
        } catch {
            throw FirestoreError(error)
        }
    }
    
    
    func add(response: ModelsR4.QuestionnaireResponse) async throws {
        do {
            let id = response.identifier?.value?.value?.string ?? UUID().uuidString
            try await Firestore.questionnaireResponseCollectionReference.document(id).setData(from: response)
        } catch {
            throw FirestoreError(error)
        }
    }

    func deletedAccount() async throws {
        // account deletion prohibited
        throw FirebaseError.accountDeletionNotAllowed
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
            _ = try await Storage.userBucketReference.child("consent").child("consent.pdf").putDataAsync(consentData, metadata: metadata)
        } catch {
            logger.error("Could not store consent form: \(error)")
        }
    }


    func create(_ identifier: AdditionalRecordId, _ details: SignupDetails) async throws {
        guard let accountStorage else {
            preconditionFailure("Account Storage was requested although not enabled in current configuration.")
        }
        try await accountStorage.create(identifier, details)
    }

    func load(_ identifier: AdditionalRecordId, _ keys: [any AccountKey.Type]) async throws -> PartialAccountDetails {
        guard let accountStorage else {
            preconditionFailure("Account Storage was requested although not enabled in current configuration.")
        }
        return try await accountStorage.load(identifier, keys)
    }

    func modify(_ identifier: AdditionalRecordId, _ modifications: AccountModifications) async throws {
        guard let accountStorage else {
            preconditionFailure("Account Storage was requested although not enabled in current configuration.")
        }
        try await accountStorage.modify(identifier, modifications)
    }

    func clear(_ identifier: AdditionalRecordId) async {
        guard let accountStorage else {
            preconditionFailure("Account Storage was requested although not enabled in current configuration.")
        }
        await accountStorage.clear(identifier)
    }

    func delete(_ identifier: AdditionalRecordId) async throws {
        guard let accountStorage else {
            preconditionFailure("Account Storage was requested although not enabled in current configuration.")
        }
        try await accountStorage.delete(identifier)
    }
}
