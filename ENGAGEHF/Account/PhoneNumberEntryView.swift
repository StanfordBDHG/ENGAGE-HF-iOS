//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount
import SpeziValidation
import SpeziViews
import SwiftUI


private struct PhoneNumberEntryStep: View {
    @State private var viewState = ViewState.idle
    @EnvironmentObject private var phoneNumberViewModel: PhoneNumberViewModel
    let onNext: () -> Void

   
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("Enter your phone number and we'll send you a verification code to add the number to your account.")
                .font(.caption)
                .multilineTextAlignment(.center)
            PhoneNumberEntryField()
            Spacer()
            Spacer()
            AsyncButton(action: {
                do {
                    try await phoneNumberViewModel.startPhoneNumberVerification()
                    onNext()
                } catch {
                    viewState = .error(
                        AnyLocalizedError(
                            error: error,
                            defaultErrorDescription: "Failed to send verification message. Please check your phone number and try again."
                        )
                    )
                }
            }) {
                Text("Send Verification Message")
                    .frame(maxWidth: .infinity, minHeight: 38)
            }
                .buttonStyle(.borderedProminent)
                .disabled(phoneNumberViewModel.phoneNumber.isEmpty)
                .viewStateAlert(state: $viewState)
        }
            .padding()
    }
}


private struct VerificationCodeStep: View {
    @State private var viewState = ViewState.idle
    @EnvironmentObject private var phoneNumberViewModel: PhoneNumberViewModel
    let codeLength: Int
    let onVerify: () -> Void
    
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Enter your \(codeLength) digit verification code you received via text message.")
                .font(.caption)
                .multilineTextAlignment(.center)
            OTCEntryView(codeLength: codeLength)
                .keyboardType(.numberPad)
            Spacer()
            AsyncButton(action: {
                do {
                    try await phoneNumberViewModel.verifyPhoneNumber()
                    onVerify()
                } catch {
                    viewState = .error(
                        AnyLocalizedError(
                            error: error,
                            defaultErrorDescription: "Failed to verify phone number. Please check your code and try again."
                        )
                    )
                }
            }) {
                Text("Verify Phone Number")
                    .frame(maxWidth: .infinity, minHeight: 38)
            }
                .buttonStyle(.borderedProminent)
                .disabled(phoneNumberViewModel.verificationCode.count < codeLength)
                .viewStateAlert(state: $viewState)
        }
            .padding()
    }
}


struct PhoneNumberEntryView: DataEntryView {
    enum VerificationStep {
        case phoneNumber
        case verificationCode
    }
    @Binding private var phoneNumbers: [String]
    @State private var phoneNumberViewModel = PhoneNumberViewModel()
    @State private var currentStep: VerificationStep = .phoneNumber
    @State private var presentSheet = false
    @State private var showDiscardAlert = false
    let codeLength = 6
    
    
    var body: some View {
        VStack {
            ForEach(phoneNumbers, id: \.self) { number in
                ListRow(number) { }
            }
            Button("Add Phone Number") {
                presentSheet.toggle()
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
                    codeLength: codeLength,
                    onVerify: {
                        phoneNumbers.append(phoneNumberViewModel.phoneNumber)
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
    
    init(_ value: Binding<[String]>) {
        self._phoneNumbers = value
    }
    
    private func resetState() {
        currentStep = .phoneNumber
        phoneNumberViewModel.phoneNumber = ""
        phoneNumberViewModel.verificationCode = ""
    }
}


#if DEBUG
#Preview {
    PhoneNumberEntryView(.constant([]))
}
#endif
