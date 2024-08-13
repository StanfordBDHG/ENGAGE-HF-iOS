//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount
import SpeziViews
import SwiftUI


private struct ENGAGEHFAppTestingSetup: ViewModifier {
    @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false

    @Environment(Account.self) private var account: Account?
    @Environment(InvitationCodeModule.self) private var invitationCodeModule

    @State private var viewState: ViewState = .idle

    func body(content: Content) -> some View {
        content
            .task {
                if FeatureFlags.assumeOnboardingComplete {
                    completedOnboardingFlow = true
                }
                if FeatureFlags.showOnboarding {
                    completedOnboardingFlow = false
                }
                if FeatureFlags.setupTestEnvironment {
                    guard let account else {
                        preconditionFailure("Account feature must be enabled to support `setupTestEnvironment` flag!")
                    }
                    do {
                        try await invitationCodeModule.setupTestEnvironment(account: account, invitationCode: "ENGAGETEST1")
                    } catch {
                        viewState = .error(AnyLocalizedError(error: error, defaultErrorDescription: "Testing setup couldn't be set up."))
                    }
                }
            }
            .viewStateAlert(state: $viewState)
    }
}


extension View {
    func testingSetup() -> some View {
        self.modifier(ENGAGEHFAppTestingSetup())
    }
}
