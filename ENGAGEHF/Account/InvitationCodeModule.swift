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
import SpeziFirebaseConfiguration


class InvitationCodeModule: Module, EnvironmentAccessible {
    @Application(\.logger) private var logger

    @Dependency(ConfigureFirebaseApp.self) private var firebase
    @Dependency(FirebaseAccountService.self) private var accountService: FirebaseAccountService?

    func configure() {
        if FeatureFlags.useFirebaseEmulator {
            Functions.functions().useEmulator(withHost: "localhost", port: 5001)
        }
    }

    func signOutAccount() {
        do {
            try Auth.auth().signOut()
        } catch {
            logger.debug("Failed to sing out firebase account: \(error)")
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
                try Auth.auth().signOut()

                try await Auth.auth().signInAnonymously()
                let checkInvitationCode = Functions.functions().httpsCallable("checkInvitationCode")

                do {
                    _ = try await checkInvitationCode.call(
                        [
                            "invitationCode": invitationCode
                        ]
                    )
                } catch {
                    logger.error("Failed to check invitation code: \(error)")
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
    func setupTestEnvironment(account: Account, invitationCode: String) async throws {
        let email = "test@engage.stanford.edu"
        let password = "123456789"

        // let the initial stateChangeDelegate of FirebaseAuth get called. Otherwise, we will interfere with that.
        try await Task.sleep(for: .milliseconds(500))

        if let details = account.details,
           details.email == email {
            logger.debug("Test account was already set up")
            return
        }

        guard let accountService else {
            preconditionFailure("The Firebase Account Service is required to be configured when setting up the test environment!")
        }

        do {
            try await accountService.login(userId: email, password: password)
            return // account was already established previously
        } catch {
            // TODO: Check for the specific error!
            logger.debug("We failed to login with test account. This might be expected if it is a fresh installation: \(error)")
            // probably doesn't exists. We try to create a new one below
        }

        try await verifyOnboardingCode(invitationCode)
        try await setupTestAccount(service: accountService, email: email, password: password)
    }

    private func setupTestAccount(service: FirebaseAccountService, email: String, password: String) async throws {
        do {
            var details = AccountDetails()
            details.userId = email
            details.password = password
            details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
            try await service.signUp(with: details)
        } catch {
            logger.error("Failed setting up test account : \(error)")
            throw error
        }
    }
}
