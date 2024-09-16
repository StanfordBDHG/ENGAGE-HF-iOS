//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Firebase
import FirebaseAuth
import FirebaseFunctions
import Spezi
import SpeziAccount
import SpeziFirebaseAccount
import SpeziFirestore


class InvitationCodeModule: Module, EnvironmentAccessible {
    @Application(\.logger) private var logger

    @Dependency(Account.self) private var account: Account?
    @Dependency(FirebaseAccountService.self) private var accountService: FirebaseAccountService?

    func configure() {
        if FeatureFlags.useFirebaseEmulator {
            let firestoreHost = FeatureFlags.useCustomFirestoreHost ? FirestoreSettings.customHost : FirestoreSettings.defaultHost
            Functions.functions().useEmulator(withHost: firestoreHost, port: 5001)
        }
    }

    func verifyOnboardingCode(_ invitationCode: String) async throws {
        do {
            if FeatureFlags.disableFirebase {
                guard invitationCode == "ENGAGEHFTEST1" else {
                    throw InvitationCodeError.invitationCodeInvalid
                }
                
                try? await Task.sleep(for: .seconds(0.25))
            } else {
                do {
                    logger.debug("About to enroll user")
                    let enrollUser = Functions.functions().httpsCallable("enrollUser")
                    _ = try await enrollUser.call(["invitationCode": invitationCode])
                    _ = try? await Auth.auth().currentUser?.getIDToken(forcingRefresh: true)
                    logger.debug("Successfully enrolled user!")
                } catch {
                    logger.error("Failed to enroll user: \(error)")
                    throw InvitationCodeError.invitationCodeInvalid
                }
            }
        } catch let error as NSError {
            if let errorCode = FunctionsErrorCode(rawValue: error.code) {
                // Handle Firebase-specific errors.
                switch errorCode {
                case .unauthenticated:
                    throw InvitationCodeError.userNotAuthenticated
                case .notFound:
                    throw InvitationCodeError.invitationCodeInvalid
                default:
                    throw InvitationCodeError.generalError(error.localizedDescription)
                }
            } else {
                // Handle other errors, such as network issues or unexpected behavior.
                throw InvitationCodeError.generalError(error.localizedDescription)
            }
        }
    }

    @MainActor
    func setupTestEnvironment(invitationCode: String) async throws {
        guard let account else {
            preconditionFailure("Account feature must be enabled to support `setupTestEnvironment` flag!")
        }

        guard let accountService else {
            preconditionFailure("The Firebase Account Service is required to be configured when setting up the test environment!")
        }

        let email = "test@engage.stanford.edu"
        let password = "123456789"

        if account.details != nil {
            // always start logged out, even if testing account had already been set up
            try await accountService.logout()
        }

        do {
            try await accountService.login(userId: email, password: password)
            return // account was already established previously
        } catch FirebaseAccountError.invalidCredentials {
            // probably doesn't exist. We try to create a new one below
        } catch {
            logger.error("Failed logging into test account: \(error)")
            throw error
        }
        
        do {
            var details = AccountDetails()
            details.userId = email
            details.password = password
            details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
            try await accountService.signUp(with: details)
            try await verifyOnboardingCode(invitationCode)
        } catch {
            logger.error("Failed setting up test account : \(error)")
            throw error
        }
    }
}
