//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount
import SwiftUI


struct DisplayView: DataDisplayView {
    private var phoneNumbers: AccountDetails.PhoneNumberArray
    
    var body: some View {
        List(phoneNumbers.numbers) {
            Text($0)
        }
    }
    
    init(_ value: AccountDetails.PhoneNumberArray) {
        self.phoneNumbers = value
    }
}

#Preview {
    DisplayView(AccountDetails.PhoneNumberArray())
}
