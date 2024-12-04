//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct ColorKeyEntryView: View {
    let color: Color
    let interpretation: String
    
    
    var body: some View {
        HStack(alignment: .center) {
            Circle()
                .fill(color)
                .frame(width: 24)
            Text(interpretation)
        }
    }
}


#Preview {
    List {
        ColorKeyEntryView(color: .green, interpretation: "Target does reached.")
    }
}
