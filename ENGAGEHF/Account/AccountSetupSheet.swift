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


private struct AccountInvitationCodeView: View {
    @Environment(Account.self) private var account

    var body: some View {
        InvitationCodeView()
    }
}


struct AccountSetupSheet: View {
    struct AccountOnboarding: View {
        @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath
        
        var body: some View {
            AccountSetup { _ in
                onboardingNavigationPath.nextStep()
            } header: {
                AccountSetupHeader()
            }
        }
    }
    
    @Binding private var isLoginActive: Bool
    
    var body: some View {
        OnboardingStack(onboardingFlowComplete: !$isLoginActive) {
            AccountInvitationCodeView() // we need this indirection, otherwise the onChange doesn't trigger
            AccountOnboarding()
                .onAppear { isLoginActive = true }
            AccountFinish()
        }
        .onAppear { isLoginActive = false }
        .interactiveDismissDisabled(isLoginActive)
    }
    
    init(isLoginActive: Binding<Bool>) {
        self._isLoginActive = isLoginActive
    }
}


#if DEBUG
#Preview {
    Text(verbatim: "Base View")
        .sheet(isPresented: .constant(true)) {
            AccountSetupSheet(isLoginActive: .constant(true))
        }
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService())
            InvitationCodeModule()
        }
}
#endif
