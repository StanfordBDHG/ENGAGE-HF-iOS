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


struct EntryView: DataEntryView {
    @Binding private var phoneNumbers: AccountDetails.PhoneNumberArray
    @State var shouldPresentSheet = false
    @State private var currentStep: VerificationStep = .phoneNumber
    @State private var phoneNumber: String = ""
    @State private var verificationCode: String = ""
    @State private var showDiscardAlert = false

    enum VerificationStep {
        case phoneNumber
        case verificationCode
    }

    
    var body: some View {
        List(phoneNumbers.numbers) {
            Text($0)
        }
        Button("Add Phone Number") {
            shouldPresentSheet.toggle()
        }
        // swiftlint:disable:next closure_body_length
        .sheet(isPresented: $shouldPresentSheet) {
            // swiftlint:disable:next closure_body_length
            NavigationStack {
                Group {
                    switch currentStep {
                    case .phoneNumber:
                        PhoneNumberEntryView(
                            phoneNumber: $phoneNumber,
                            onNext: {
                                currentStep = .verificationCode
                            }
                        )
                    case .verificationCode:
                        VerificationCodeView(
                            verificationCode: $verificationCode,
                            phoneNumber: phoneNumber,
                            onVerify: {
                                phoneNumbers.numbers.append(phoneNumber)
                                shouldPresentSheet = false
                            }
                        )
                    }
                }
                .navigationTitle(currentStep == .phoneNumber ? "Add Phone Number" : "Verify Number")
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
                    Button("Cancel", role: .cancel) {
                    }
                } message: {
                    Text("You have unsaved changes. Are you sure you want to discard them?")
                }
            }
            .interactiveDismissDisabled(!phoneNumber.isEmpty)
            .presentationDetents([.medium])
            .onDisappear {
                resetState()
            }
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


private struct PhoneNumberEntryView: View {
    @Binding var phoneNumber: String
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            TextField("Phone Number", text: $phoneNumber)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.phonePad)
            Spacer()
            Spacer()
            AsyncButton(action: {
                Task {
                    try await startPhoneNumberVerification(phoneNumber: phoneNumber)
                    onNext()
                }
            }) {
                Text("Send Verification Message")
                    .frame(maxWidth: .infinity, minHeight: 38)
            }
                .buttonStyle(.borderedProminent)
                .disabled(phoneNumber.isEmpty)
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

private struct VerificationCodeView: View {
    @Binding var verificationCode: String
    let phoneNumber: String
    let onVerify: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Enter your 6 digit verification code you received via text message.")
                .font(.caption)
                .multilineTextAlignment(.center)
            OTCEntryView(code: $verificationCode)
                .keyboardType(.numberPad)
            Spacer()
            AsyncButton(action: {
                Task {
                    try await verifyPhoneNumber(verificationCode: verificationCode)
                    onVerify()
                }
            }) {
                Text("Verify")
                    .frame(maxWidth: .infinity, minHeight: 38)
            }
                .buttonStyle(.borderedProminent)
                .disabled(verificationCode.isEmpty)
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

#Preview {
    EntryView(.constant(AccountDetails.PhoneNumberArray()))
}
