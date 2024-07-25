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
    enum ENGAGEHFStandardError: LocalizedError {
        case invalidHKSampleType
        case accountDeletionNotAllowed
        
        var errorDescription: String? {
            switch self {
            case .invalidHKSampleType: String(localized: "invalidHKSample")
            case .accountDeletionNotAllowed: String(localized: "accountDeletionError")
            }
        }
    }

    @Dependency var accountStorage: FirestoreAccountStorage?

    @AccountReference var account: Account

    private let logger = Logger(subsystem: "ENGAGEHF", category: "Standard")
    

    func addMeasurement(samples: [HKSample]) async throws {
        guard !samples.isEmpty else {
            return
        }

        logger.debug("Saving \(samples.count) samples to firestore ...")
        let patientDocumentReference = try await Firestore.patientDocumentReference

        do {
            let batch = Firestore.firestore().batch()
            for sample in samples {
                do {
                    let document = try healthKitDocument(for: patientDocumentReference, id: sample.id, type: sample.sampleType)
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
    
    
    func add(symptomScore: SymptomScore) async {
        do {
            let patientDoc = try await Firestore.patientDocumentReference
            try patientDoc.collection("symptomScores").addDocument(from: symptomScore)
        } catch {
            logger.error("Could not store the symptom scores: \(error)")
        }
    }
    
    
    func add(notification: Notification) async {
        do {
            let userDoc = try await Firestore.userDocumentReference
            try userDoc.collection("messages").addDocument(from: notification)
        } catch {
            logger.error("Could not store the notification: \(error)")
        }
    }
    
    
    func add(response: ModelsR4.QuestionnaireResponse) async {
        let id = response.identifier?.value?.value?.string ?? UUID().uuidString
        
        do {
            try await Firestore.patientDocumentReference
                .collection("QuestionnaireResponse") // Add all HealthKit sources in a /QuestionnaireResponse collection.
                .document(id) // Set the document identifier to the id of the response.
                .setData(from: response)
        } catch {
            logger.error("Could not store questionnaire response: \(error)")
        }
    }
    

    private func healthKitDocument(for user: DocumentReference, id uuid: UUID, type: HKSampleType) throws -> DocumentReference {
        var collectionBucket: String? {
            switch type {
            case HKQuantityType(.bodyMass):
                return CollectionID.bodyWeightObservations.rawValue
            case HKQuantityType(.bodyMassIndex):
                return nil
            case HKQuantityType(.height):
                return nil
            case HKQuantityType(.heartRate):
                return CollectionID.heartRateObservations.rawValue
            case HKCorrelationType(.bloodPressure):
                return CollectionID.bloodPressureObservations.rawValue
            default:
                return nil
            }
        }
        
        guard let collectionBucket else {
            throw ENGAGEHFStandardError.invalidHKSampleType
        }
        
        return user
            .collection(collectionBucket)
            .document(uuid.uuidString) // Set the document identifier to the UUID of the document.
    }

    func deletedAccount() async throws {
        // account deletion prohibited
        throw ENGAGEHFStandardError.accountDeletionNotAllowed
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
            _ = try await Storage.patientBucketReference.child("consent.pdf").putDataAsync(consentData, metadata: metadata)
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
