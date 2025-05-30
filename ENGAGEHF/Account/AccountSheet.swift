//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFunctions
@_spi(TestingSupport) import SpeziAccount
import SpeziLicense
import SwiftUI


struct AccountSheet: View {
    @State private var questionnaireId: String?
    
    var body: some View {
        NavigationStack {
            AccountOverview(close: .showCloseButton, deletion: .disabled) {
                AdditionalAccountSections(questionnaireId: $questionnaireId)
            }
            .sheet(item: $questionnaireId) { questionnaireId in
                QuestionnaireSheetView(questionnaireId: questionnaireId)
            }
        }
    }
}


#if DEBUG
#Preview("AccountSheet") {
    var details = AccountDetails()
    details.userId = "lelandstanford@stanford.edu"
    details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")

    return AccountSheet()
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService(), activeDetails: details)
        }
}

#Preview("AccountSheet Disabled") {
    var details = AccountDetails()
    details.userId = "lelandstanford@stanford.edu"
    details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
    details.disabled = true

    return AccountSheet()
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService(), activeDetails: details)
        }
}

#Preview("AccountSheet SignIn") {
    AccountSheet()
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService())
        }
}
#endif
