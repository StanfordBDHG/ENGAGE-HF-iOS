//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFunctions
import PhoneNumberKit
import SpeziAccount
import SpeziValidation
import SpeziViews
import SwiftUI


private struct PhoneNumberEntryStep: View {
    @Binding var phoneNumber: String
    @State var displayedPhoneNumber = ""
    @State var selectedRegion = "US"
    let onNext: () -> Void
    @State private var viewState = ViewState.idle
    @State private var presentSheet = false
    @State private var searchCountry = ""
    let phoneNumberUtility = PhoneNumberUtility()
    
   
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            HStack(spacing: 15) {
                countryPickerButton
                phoneNumberEntryField
            }
                .padding(6)
                .background(Color(uiColor: .secondarySystemBackground))
                .mask(RoundedRectangle(cornerRadius: 8))
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
            .sheet(isPresented: $presentSheet) {
                countryPickerSheet
            }
    }

    
    var countryPickerButton: some View {
        Button {
            presentSheet = true
        } label: {
            Text(
                countryFlag(for: selectedRegion) +
                " " +
                "+\(phoneNumberUtility.countryCode(for: selectedRegion)?.description ?? "")"
            )
                .foregroundColor(.secondary)
                .padding([.leading, .trailing], 15)
                .padding([.top, .bottom], 7)
                .frame(minWidth: 50)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(uiColor: .tertiarySystemFill))
                )
        }
    }
    
    var countryPickerSheet: some View {
        NavigationView {
            List(filteredCountries, id: \.self) { country in
                HStack(spacing: 15) {
                    Text(countryFlag(for: country))
                    Text(country)
                        .font(.headline)
                    Spacer()
                    Text("+" + (phoneNumberUtility.countryCode(for: country)?.description ?? ""))
                        .foregroundColor(.secondary)
                }
                    .onTapGesture {
                        selectedRegion = country
                        presentSheet = false
                        searchCountry = ""
                    }
            }
                .listStyle(.plain)
                .searchable(text: $searchCountry, prompt: "Your country")
        }
            .padding(.top, 5)
            .presentationDetents([.medium, .large])
    }

    var phoneNumberEntryField: some View {
        VerifiableTextField(
            "Phone Number",
            text: $displayedPhoneNumber
        )
            .validate(input: displayedPhoneNumber, rules: [
                ValidationRule(
                    rule: {[phoneNumberUtility, selectedRegion] number in
                        print(selectedRegion)
                        return phoneNumberUtility.isValidPhoneNumber(number, withRegion: selectedRegion) || number.isEmpty
                    },
                    message: "The entered phone number is invalid."
                )
            ])
            .textContentType(.telephoneNumber)
            .keyboardType(.phonePad)
            .onChange(of: displayedPhoneNumber) { _, newValue in
                do {
                    let number = try phoneNumberUtility.parse(newValue, withRegion: selectedRegion)
                    displayedPhoneNumber = phoneNumberUtility.format(number, toType: .national)
                    phoneNumber = phoneNumberUtility.format(number, toType: .e164)
                } catch {
                    phoneNumber = ""
                }
            }
            .id(selectedRegion) // to trigger a update of the validation rule upon changes of selectedRegion
    }
    
    private var filteredCountries: [String] {
        if searchCountry.isEmpty {
            return phoneNumberUtility.allCountries()
        } else {
            return phoneNumberUtility.allCountries().filter { country in
                let countryCode = phoneNumberUtility.countryCode(for: country)?.description ?? ""
                return country.lowercased().contains(searchCountry.lowercased()) ||
                countryCode.contains(searchCountry)
            }
        }
    }
    
    func countryFlag(for country: String) -> String {
        let flagBase = UnicodeScalar("🇦").value - UnicodeScalar("A").value
        return country
            .uppercased()
            .unicodeScalars
            .compactMap { UnicodeScalar(flagBase + $0.value)?.description }
            .joined()
    }
   
    func startPhoneNumberVerification(phoneNumber: String) async throws {
        let functions = Functions.functions()
        let data: [String: String] = [
            "phoneNumber": phoneNumber
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
        let data: [String: String] = [
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
    @Binding private var phoneNumbers: PhoneNumberArray
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
    
    init(_ value: Binding<PhoneNumberArray>) {
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
    PhoneNumberEntryView(.constant(PhoneNumberArray()))
}
#endif
