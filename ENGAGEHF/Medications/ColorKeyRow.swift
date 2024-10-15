//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct ColorKeyRow: View {
    let color: Color
    let description: String
    
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12)
            Text(description)
        }
    }
}
