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


struct AccountFinish: View {
    @Environment(Account.self) private var account
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath
    
    @State private var viewState = ViewState.processing
    
    var body: some View {
        VStack {
            switch viewState {
            case .idle:
                Text("Account Creation Finished!")
                    .font(.title)
                Text("Your account has successfully been created. You may now proceed.")
                    .font(.headline)
                
                Button("Continue") {
                    onboardingNavigationPath.nextStep()
                }
            case .processing:
                ProgressView()
            case let .error(error):
                Text("Error occured: \(error.errorDescription ?? "")")
                
                Button("Try again") {
                    onboardingNavigationPath.removeLast()
                }
            }
        }
        .task {
            do {
                try await account.finishSetupIfNeeded()
                viewState = .idle
            } catch {
                viewState = .error(AnyLocalizedError(error: error))
            }
        }
        .navigationTitle(Text("Finishing Account Setup"))
        .navigationBarBackButtonHidden(true)
    }
}


#if DEBUG
#Preview("Account Finish SignIn") {
    OnboardingStack {
        AccountFinish()
    }
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService())
        }
}

#Preview("Account Finish SignUp") {
    var details = AccountDetails()
    details.userId = "lelandstanford@stanford.edu"
    details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")

    return OnboardingStack {
        AccountFinish()
    }
        .previewWith {
            AccountConfiguration(service: InMemoryAccountService(), activeDetails: details)
        }
}
#endif
