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
import SpeziFirebaseConfiguration


class InvitationCodeModule: Module, EnvironmentAccessible {
    @Dependency private var firebase: ConfigureFirebaseApp

    @Application(\.logger) private var logger

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

    func setupTestEnvironment(account: Account, invitationCode: String) async throws {
        try await verifyOnboardingCode(invitationCode)
        try await setupTestAccount(account: account)
    }

    @MainActor
    private func setupTestAccount(account: Account) async throws {
        let email = "test@engage.stanford.edu"
        let password = "123456789"

        if let details = account.details,
           details.email == email {
            return
        }

        guard let service = account.registeredAccountServices.compactMap({ $0 as? any UserIdPasswordAccountService }).first else {
            preconditionFailure("Failed to retrieve a user-id-password based account service for test account setup!")
        }


        do {
            // let the initial stateChangeDelegate of FirebaseAuth get called. Otherwise, we will interfere with that.
            try await Task.sleep(for: .milliseconds(500))

            do {
                let details = SignupDetails.Builder()
                    .set(\.userId, value: email)
                    .set(\.name, value: PersonNameComponents(givenName: "Leland", familyName: "Stanford"))
                    .set(\.password, value: password)
                    .build()
                try await service.signUp(signupDetails: details)
            } catch {
                if "\(error)".contains("accountAlreadyInUse") {
                    try await service.login(userId: email, password: password)
                } else {
                    throw error
                }
            }
        } catch {
            logger.error("Failed setting up test account : \(error)")
            throw error
        }
    }
}
