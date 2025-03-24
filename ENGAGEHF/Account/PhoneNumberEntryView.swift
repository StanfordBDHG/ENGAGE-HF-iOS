//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFunctions
import SpeziAccount
import SpeziViews
import SwiftUI


private struct PhoneNumberEntryStep: View {
    @Binding var phoneNumber: String
    let onNext: () -> Void
    @State private var viewState = ViewState.idle
    
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            TextField("Phone Number", text: $phoneNumber)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.phonePad)
            Spacer()
            Spacer()
            AsyncButton(action: {
                do {
                    try await startPhoneNumberVerification(phoneNumber: phoneNumber)
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
                .disabled(phoneNumber.isEmpty)
                .viewStateAlert(state: $viewState)
        }
            .padding()
    }

    
    func startPhoneNumberVerification(phoneNumber: String) async throws {
        let formattedNumber = phoneNumber.replacingOccurrences(of: " ", with: "")
        guard formattedNumber.hasPrefix("+") else {
            return
        }
        
        let functions = Functions.functions()
        let data: [String: Any] = [
            "phoneNumber": formattedNumber
        ]
        
        _ = try await functions.httpsCallable("startPhoneNumberVerification")
            .call(data)
    }
}


private struct VerificationCodeStep: View {
    @Binding var verificationCode: String
    let codeLength: Int
    let phoneNumber: String
    let onVerify: () -> Void
    @State private var viewState = ViewState.idle
    
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Enter your \(codeLength) digit verification code you received via text message.")
                .font(.caption)
                .multilineTextAlignment(.center)
            OTCEntryView(code: $verificationCode, codeLength: codeLength)
                .keyboardType(.numberPad)
            Spacer()
            AsyncButton(action: {
                do {
                    try await verifyPhoneNumber(verificationCode: verificationCode)
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
                .disabled(verificationCode.count < codeLength)
                .viewStateAlert(state: $viewState)
        }
            .padding()
    }
    

    func verifyPhoneNumber(verificationCode: String) async throws {
        let functions = Functions.functions()
        let data: [String: Any] = [
            "phoneNumber": phoneNumber,
            "code": verificationCode
        ]
        
        _ = try await functions.httpsCallable("checkPhoneNumberVerification")
            .call(data)
    }
}


struct PhoneNumberEntryView: DataEntryView {
    enum VerificationStep {
        case phoneNumber
        case verificationCode
    }
    @Binding private var phoneNumbers: AccountDetails.PhoneNumberArray
    @State var shouldPresentSheet = false
    @State private var currentStep: VerificationStep = .phoneNumber
    @State private var phoneNumber: String = ""
    @State private var verificationCode: String = ""
    @State private var showDiscardAlert = false
    let codeLength = 6
    
    
    var body: some View {
        List(phoneNumbers.numbers) {
            Text($0)
        }
        Button("Add Phone Number") {
            shouldPresentSheet.toggle()
        }
        .sheet(isPresented: $shouldPresentSheet) {
            NavigationStack {
                phoneEntrySteps
            }
            .interactiveDismissDisabled(!phoneNumber.isEmpty)
            .presentationDetents([.medium])
            .onDisappear {
                resetState()
            }
        }
    }
    
    
    private var phoneEntrySteps: some View {
        Group {
            switch currentStep {
            case .phoneNumber:
                PhoneNumberEntryStep(
                    phoneNumber: $phoneNumber,
                    onNext: {
                        currentStep = .verificationCode
                    }
                )
            case .verificationCode:
                VerificationCodeStep(
                    verificationCode: $verificationCode,
                    codeLength: codeLength,
                    phoneNumber: phoneNumber,
                    onVerify: {
                        phoneNumbers.numbers.append(phoneNumber)
                        shouldPresentSheet = false
                    }
                )
            }
        }
        .navigationTitle(currentStep == .phoneNumber ? "Add Phone Number" : "Enter Verification Code")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    if !phoneNumber.isEmpty {
                        showDiscardAlert = true
                    } else {
                        shouldPresentSheet = false
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
                shouldPresentSheet = false
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You have unsaved changes. Are you sure you want to discard them?")
        }
    }
    
    init(_ value: Binding<AccountDetails.PhoneNumberArray>) {
        self._phoneNumbers = value
    }
    
    private func resetState() {
        currentStep = .phoneNumber
        phoneNumber = ""
        verificationCode = ""
    }
}


#if DEBUG
#Preview {
    PhoneNumberEntryView(.constant(AccountDetails.PhoneNumberArray()))
}
#endif
