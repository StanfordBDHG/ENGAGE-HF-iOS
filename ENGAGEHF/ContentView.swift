//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

@_spi(TestingSupport) import SpeziAccount
import SpeziOnboarding
import SpeziViews
import SwiftUI


@MainActor
struct ContentView: View {
    private enum SheetContent: String, Identifiable {
        case onboarding
        case auth
        
        var id: String {
            rawValue
        }
    }
    
    
    @AppStorage(StorageKeys.onboardingFlowComplete) private var completedOnboardingFlow = false
    @Environment(Account.self) private var account: Account?

    
    private var expectedSheetContent: SheetContent? {
        guard FeatureFlags.skipOnboarding || completedOnboardingFlow else {
            return .onboarding
        }
        guard FeatureFlags.disableFirebase || account?.signedIn ?? false else {
            return .auth
        }
        guard FeatureFlags.disableFirebase
                || !(account?.details?.isIncomplete ?? true)
                || account?.details?.invitationCode != nil else {
            return .auth
        }
        return nil
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            if account?.signedIn ?? false {
                HomeView()
            } else {
                Image(.engagehfIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 128, height: 128)
                    .clipShape(RoundedRectangle(cornerRadius: 32))
                    .accessibilityLabel("ENGAGE-HF Application Loading Screen")
            }
        }
            .accountRequired(
                accountSetupIsComplete: { _ in
                    expectedSheetContent == nil
                },
                setupSheet: {
                    switch expectedSheetContent {
                    case .onboarding:
                        OnboardingFlow()
                            .interactiveDismissDisabled(true)
                    case .auth:
                        AuthFlow()
                            .interactiveDismissDisabled(true)
                    case .none:
                        EmptyView()
                    }
                }
            )
    }
}
