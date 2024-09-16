//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount
import SpeziOnboarding
import SpeziValidation
import SpeziViews
import SwiftUI

@MainActor
struct InvitationCodeView: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath
    @Environment(InvitationCodeModule.self) private var invitationCodeModule
    @Environment(Account.self) private var account

    @State private var invitationCode = ""
    @State private var viewState: ViewState = .idle
    
    @ValidationState private var validation
    

    private var invitationCodeValidationRule: ValidationRule {
        ValidationRule(
            rule: { invitationCode in
                invitationCode.count >= 8
            },
            message: "An invitation code is at least 8 characters long."
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                invitationCodeHeader
                Divider()
                Grid(horizontalSpacing: 16, verticalSpacing: 16) {
                    invitationCodeView
                }
                    .padding(.top, -8)
                    .padding(.bottom, -12)
                Divider()
                actionsView
            }
                .padding(.horizontal)
                .padding(.bottom)
                .viewStateAlert(state: $viewState)
                .navigationBarTitleDisplayMode(.large)
                .navigationTitle(String(localized: "Invitation Code"))
        }
        .navigationBarBackButtonHidden()
    }
    
    @ViewBuilder private var actionsView: some View {
        OnboardingActionsView(
            primaryText: "Redeem Invitation Code",
            primaryAction: {
                guard validation.validateSubviews() else {
                    return
                }
                do {
                    try await invitationCodeModule.verifyOnboardingCode(invitationCode)
                    onboardingNavigationPath.nextStep()
                } catch {
                    viewState = .error(AnyLocalizedError(error: error))
                }
            },
            secondaryText: "Logout",
            secondaryAction: {
                do {
                    try await account.accountService.logout()
                    onboardingNavigationPath.removeLast()
                } catch {
                    viewState = .error(AnyLocalizedError(error: error))
                }
            }
        )
    }
    
    @ViewBuilder private var invitationCodeView: some View {
        DescriptionGridRow {
            Text("Invitation Code")
        } content: {
            VerifiableTextField(
                "Invitation Code",
                text: $invitationCode
            )
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.characters)
                .textContentType(.oneTimeCode)
                .validate(input: invitationCode, rules: [invitationCodeValidationRule])
        }
            .receiveValidation(in: $validation)
    }
    
    @ViewBuilder private var invitationCodeHeader: some View {
        VStack(spacing: 32) {
            Image(systemName: "rectangle.and.pencil.and.ellipsis")
                .resizable()
                .scaledToFit()
                .frame(height: 100)
                .accessibilityHidden(true)
                .foregroundStyle(Color.accentColor)
            Text("Please enter your invitation code to join the ENGAGE-HF study.")
        }
    }
}


#Preview {
    OnboardingStack {
        InvitationCodeView()
    }
        .previewWith(standard: ENGAGEHFStandard()) {
            InvitationCodeModule()
        }
}
