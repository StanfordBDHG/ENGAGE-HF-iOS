//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct HeartHealth: View {
    @Binding var presentingAccount: Bool
    
    
    var body: some View {
        Text("Heart Health Test")
            .accessibilityLabel(Text("HH"))
    }
}
