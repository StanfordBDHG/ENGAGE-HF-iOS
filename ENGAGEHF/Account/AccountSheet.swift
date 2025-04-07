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
    enum VerificationStep {
        case phoneNumber
        case verificationCode
    }
    @State private var presentSheet = false
    @StateObject var phoneNumberViewModel = PhoneNumberViewModel()
    @State private var currentStep: VerificationStep = .phoneNumber
    @State private var showDiscardAlert = false
    
    var body: some View {
        NavigationStack {
            AccountOverview(close: .showCloseButton, deletion: .disabled) {
                AdditionalAccountSections(presentSheet: $presentSheet)
            }
        }
        .sheet(isPresented: $presentSheet) {
            NavigationStack {
                phoneEntrySteps
            }
            .interactiveDismissDisabled(!phoneNumberViewModel.phoneNumber.isEmpty)
            .presentationDetents([.medium])
            .onDisappear {
                resetState()
            }
            .environment(phoneNumberViewModel)
        }
    }
    
    private func resetState() {
        currentStep = .phoneNumber
        phoneNumberViewModel.phoneNumber = ""
        phoneNumberViewModel.verificationCode = ""
    }
    
    private var phoneEntrySteps: some View {
        Group {
            switch currentStep {
            case .phoneNumber:
                PhoneNumberEntryStep(
                    onNext: {
                        currentStep = .verificationCode
                    }
                )
            case .verificationCode:
                VerificationCodeStep(
                    codeLength: 6,
                    onVerify: {
                        // phoneNumbers.append(phoneNumberViewModel.phoneNumber)
                        presentSheet = false
                    }
                )
            }
        }
        .navigationTitle(currentStep == .phoneNumber ? "Add Phone Number" : "Enter Verification Code")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    if !phoneNumberViewModel.phoneNumber.isEmpty {
                        showDiscardAlert = true
                    } else {
                        presentSheet = false
                    }
                }
            }
        }
        .confirmationDialog(
            "Discard Changes?",
            isPresented: $showDiscardAlert,
            titleVisibility: .visible
        ) {
            Button("Discard", role: .destructive) {
                presentSheet = false
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You have unsaved changes. Are you sure you want to discard them?")
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
