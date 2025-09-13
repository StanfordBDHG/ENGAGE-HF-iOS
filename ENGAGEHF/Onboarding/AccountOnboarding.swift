//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFunctions
import Spezi
@_spi(TestingSupport) import SpeziAccount
import SpeziOnboarding
import SpeziViews
import SwiftUI


struct AccountOnboarding: View {
    @Environment(Account.self) private var account
    @Environment(ManagedNavigationStack.Path.self) private var managedNavigationStackPath
    
    var body: some View {
        AccountSetup { details in
            if details.invitationCode != nil {
                managedNavigationStackPath.nextStep()
            } else {
                managedNavigationStackPath.append(customView: InvitationCodeView())
            }
        } header: {
            AccountSetupHeader()
        } continue: {
            OnboardingActionsView(
                "ACCOUNT_NEXT",
                action: {
                    if account.details?.invitationCode != nil {
                        managedNavigationStackPath.nextStep()
                    } else {
                        managedNavigationStackPath.append(customView: InvitationCodeView())
                    }
                }
            )
        }
            .preferredAccountSetupStyle(.login)
    }
}


#if DEBUG
#Preview("Account Onboarding SignIn") {
    ManagedNavigationStack {
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

    return ManagedNavigationStack {
        AccountOnboarding()
    }
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService(), activeDetails: details)
        }
}
#endif
