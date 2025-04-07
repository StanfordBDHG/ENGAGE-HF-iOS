//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount
import SpeziViews
import SwiftUI


struct PhoneNumberDisplayView: DataDisplayView {
    private var phoneNumbers: [String]
    
    
    var body: some View {
        ForEach(phoneNumbers, id: \.self) { number in
            ListRow(number) {
            }
        }
    }
    
    init(_ value: [String]) {
        self.phoneNumbers = value
    }
}


#if DEBUG
#Preview {
    PhoneNumberDisplayView([])
}
#endif
