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
    
    @State private var viewState = ViewState.idle

    var body: some View {
        AccountSetup { details in
            if details.invitationCode != nil {
                onboardingNavigationPath.nextStep()
            } else {
                onboardingNavigationPath.append(customView: InvitationCodeView())
            }
        } header: {
            AccountSetupHeader()
        } continue: {
            OnboardingActionsView(
                "ACCOUNT_NEXT",
                action: {
                    if account.details?.invitationCode != nil {
                        onboardingNavigationPath.nextStep()
                    } else {
                        onboardingNavigationPath.append(customView: InvitationCodeView())
                    }
                }
            )
        }
            .preferredAccountSetupStyle(.login)
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
