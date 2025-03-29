//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFunctions
import PhoneNumberKit
import SwiftUI


@Observable
class PhoneNumberViewModel: ObservableObject {
    var phoneNumber = ""
    var displayedPhoneNumber = ""
    var selectedRegion = "US"
    var verificationCode = ""
    var phoneNumberUtility = PhoneNumberUtility()
    
    
    func startPhoneNumberVerification() async throws {
        let functions = Functions.functions()
        let data: [String: String] = [
            "phoneNumber": phoneNumber
        ]
        _ = try await functions.httpsCallable("startPhoneNumberVerification")
            .call(data)
    }

    func verifyPhoneNumber() async throws {
        let functions = Functions.functions()
        let data: [String: String] = [
            "phoneNumber": phoneNumber,
            "code": verificationCode
        ]
        _ = try await functions.httpsCallable("checkPhoneNumberVerification")
            .call(data)
    }
    
    func countryFlag(for country: String) -> String {
        let flagBase = UnicodeScalar("🇦").value - UnicodeScalar("A").value
        return country
            .uppercased()
            .unicodeScalars
            .compactMap { UnicodeScalar(flagBase + $0.value)?.description }
            .joined()
    }
}
