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
    private var value: PhoneNumberArray
    
    var body: some View {
        ForEach(value.numbers, id: \.self) { number in
            ListRow(number) {
                HStack {
                    Text(number)
                    Spacer()
                }
            }
        }
    }
    
    init(_ value: PhoneNumberArray) {
        self.value = value
    }
}


#if DEBUG
#Preview {
    PhoneNumberDisplayView(PhoneNumberArray())
}
#endif
