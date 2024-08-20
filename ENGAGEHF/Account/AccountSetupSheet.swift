//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

@_spi(TestingSupport) import SpeziAccount
import SpeziOnboarding
import SwiftUI


private struct AccountInvitationCodeView: View {
    @Environment(\.dismiss) private var dismiss

    @Environment(Account.self) private var account


    var body: some View {
        InvitationCodeView()
            .onChange(of: account.signedIn, initial: true) {
                if account.signedIn {
                    dismiss()
                }
            }
    }
}


struct AccountSetupSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        OnboardingStack {
            AccountInvitationCodeView() // we need this indirection, otherwise the onChange doesn't trigger
            AccountSetup { _ in
                dismiss()
            } header: {
                AccountSetupHeader()
            }
        }
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
