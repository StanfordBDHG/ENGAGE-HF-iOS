//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Firebase
import FirebaseFunctions
import Spezi
import SpeziAccount
import SpeziFirebaseAccount


class InvitationCodeModule: Module, EnvironmentAccessible {
    @Application(\.logger) private var logger

    @Dependency(FirebaseAccountService.self) private var accountService: FirebaseAccountService?

    func configure() {
        if FeatureFlags.useFirebaseEmulator {
            Functions.functions().useEmulator(withHost: "localhost", port: 5001)
        }
    }

    func signOutAccount() async {
        do {
            try await _signOutAccount()
        } catch {
            logger.debug("Failed to sing out firebase account: \(error)")
        }
    }

    private func _signOutAccount() async throws {
        do {
            try await accountService?.logout()
        } catch FirebaseAccountError.notSignedIn {
            // do nothing
        } catch {
            throw error
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
                guard let accountService else {
                    preconditionFailure("The Firebase Account Service was not present even though `disableFirebase` was turned off!")
                }

                try await _signOutAccount()
                try await accountService.signUpAnonymously()

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
        } catch FirebaseAccountError.invalidCredentials {
            // probably doesn't exists. We try to create a new one below
        } catch {
            logger.error("Failed logging into test account: \(error)")
            return
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
