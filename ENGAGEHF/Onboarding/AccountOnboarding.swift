//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFunctions
@_spi(TestingSupport) import SpeziAccount
import SpeziOnboarding
import SpeziViews
import SwiftUI


struct AccountOnboarding: View {
    @Environment(Account.self) private var account
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath

    @MainActor private var setupStyle: PreferredSetupStyle {
        if let details = account.details,
           details.isAnonymous {
            .signup
        } else {
            // when we navigate here from the InvitationCodeView we remove the anonymous account for sign in.
            .login
        }
    }
    
    @State private var viewState = ViewState.idle

    var body: some View {
        AccountSetup { _ in
            Task {
                // Placing the nextStep() call inside this task will ensure that the sheet dismiss animation is
                // played till the end before we navigate to the next step.
                onboardingNavigationPath.nextStep()
            }
        } header: {
            AccountSetupHeader()
        } continue: {
            OnboardingActionsView(
                "ACCOUNT_NEXT",
                action: {
                    onboardingNavigationPath.nextStep()
                }
            )
        }
            .preferredAccountSetupStyle(setupStyle)
            .viewStateAlert(state: $viewState)
    }
}


#if DEBUG
#Preview("Account Onboarding SignIn") {
    OnboardingStack {
        AccountOnboarding()
    }
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService())
        }
}

#Preview("Account Onboarding") {
    var details = AccountDetails()
    details.userId = "lelandstanford@stanford.edu"
    details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")

    return OnboardingStack {
        AccountOnboarding()
    }
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService(), activeDetails: details)
        }
}
#endif
