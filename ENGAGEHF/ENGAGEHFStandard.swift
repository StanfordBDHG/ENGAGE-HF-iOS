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
import SpeziFirebaseAccount
import SpeziFirestore
import SpeziHealthKit
import SpeziOnboarding
import SpeziQuestionnaire
import SwiftUI


actor ENGAGEHFStandard: Standard, EnvironmentAccessible {
    @Dependency(Account.self) private var account: Account?
    
    @Application(\.logger) private var logger
    
    
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
                    guard let collection = Firestore.collectionReference(for: accountId, type: sample.sampleType) else {
                        continue
                    }

                    let document = collection.document(sample.id.uuidString)
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
    
    
    func add(response: ModelsR4.QuestionnaireResponse) async throws {
        let accountId = try await accountId
        do {
            let id = response.identifier?.value?.value?.string ?? UUID().uuidString
            try await Firestore.questionnaireResponseCollectionReference(for: accountId).document(id).setData(from: response)
        } catch {
            throw FirestoreError(error)
        }
    }
}
