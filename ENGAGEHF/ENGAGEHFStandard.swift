//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import FirebaseFunctions
import FirebaseStorage
import HealthKit
import HealthKitOnFHIR
import OSLog
import PDFKit
import PhoneNumberKit
import Spezi
import SpeziAccount
import SpeziAccountPhoneNumbers
import SpeziDevices
import SpeziFirebaseAccount
import SpeziFirestore
import SpeziQuestionnaire
import SwiftUI


actor ENGAGEHFStandard: Standard, EnvironmentAccessible, PhoneVerificationConstraint, Sendable {
    @Dependency(Account.self) private var account: Account?
    @Dependency(MessageManager.self) private var messageManager: MessageManager
    
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
        
        messageManager.markAsProcessing(
            type: .healthMeasurement(samples: samples.count)
        )

        logger.debug("Saving \(samples.count) samples to firestore ...")
        let accountId = try await accountId

        do {
            let batch = Firestore.firestore().batch()
            for sample in samples {
                do {
                    guard let collection = Firestore.collectionReference(for: accountId, type: sample.sampleType) else {
                        continue
                    }

                    let document = collection.document(sample.uuid.uuidString)
                    try batch.setData(from: sample.resource(), forDocument: document)
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
        var questionnaireId = response.identifier?.value?.value?.string ?? UUID().uuidString

        // Use ID "0" in test mode to match test message
#if DEBUG
        if ProcessInfo.processInfo.isPreviewSimulator || FeatureFlags.setupTestMessages {
            questionnaireId = "0"
        }
#endif
        
        messageManager.markAsProcessing(
            type: .questionnaire(id: questionnaireId)
        )
        
#if DEBUG
        if ProcessInfo.processInfo.isPreviewSimulator || FeatureFlags.setupTestMessages {
            try? await Task.sleep(for: .seconds(2)) // Simulate delay
            return
        }
#endif
        
        let accountId = try await accountId
        do {
            try await Firestore.questionnaireResponseCollectionReference(for: accountId)
                .document(questionnaireId)
                .setData(from: response)
        } catch {
            throw FirestoreError(error)
        }
    }
    
    func startVerification(_ number: PhoneNumber) async throws {
        let function = Functions.functions().httpsCallable("startPhoneNumberVerification")
        let e164FormattedNumber = PhoneNumberUtility().format(number, toType: .e164)
        do {
#if DEBUG
            if FeatureFlags.setupTestPhoneNumberVerificationBehavior {
                return
            }
#endif
            _ = try await function.call(["phoneNumber": e164FormattedNumber])
        } catch {
            logger.error("Failed to start phone number verification: \(error.localizedDescription)")
            throw error
        }
    }
    
    func completeVerification(_ number: PhoneNumber, _ code: String) async throws {
        let function = Functions.functions().httpsCallable("checkPhoneNumberVerification")
        let e164FormattedNumber = PhoneNumberUtility().format(number, toType: .e164)
        do {
#if DEBUG
            if FeatureFlags.setupTestPhoneNumberVerificationBehavior {
                return
            }
#endif
            _ = try await function.call(["phoneNumber": e164FormattedNumber, "code": code])
        } catch {
            logger.error("Failed to complete phone number verification: \(error.localizedDescription)")
            throw error
        }
    }
    
    func delete(_ number: PhoneNumber) async throws {
        let function = Functions.functions().httpsCallable("deletePhoneNumber")
        let e164FormattedNumber = PhoneNumberUtility().format(number, toType: .e164)
        do {
            _ = try await function.call(["phoneNumber": e164FormattedNumber])
        } catch {
            logger.error("Failed to delete phone number: \(error.localizedDescription)")
            throw error
        }
    }
}
