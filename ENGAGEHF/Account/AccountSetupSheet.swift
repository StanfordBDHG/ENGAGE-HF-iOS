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
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        InvitationCodeView()
            .onChange(of: account.signedIn, initial: true) {
                if account.signedIn && account.details?.isAnonymous == false {
                    dismiss()
                }
            }
    }
}


struct AccountSetupSheet: View {
    @Environment(Account.self) private var account
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewState = ViewState.idle

    var body: some View {
        OnboardingStack {
            AccountInvitationCodeView() // we need this indirection, otherwise the onChange doesn't trigger
            AccountSetup { _ in
                try await account.setup()
            } header: {
                AccountSetupHeader()
            }
        }
        .viewStateAlert(state: $viewState)
    }
}


#if DEBUG
#Preview {
    Text(verbatim: "Base View")
        .sheet(isPresented: .constant(true)) {
            AccountSetupSheet()
        }
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService())
            InvitationCodeModule()
        }
}
#endif
