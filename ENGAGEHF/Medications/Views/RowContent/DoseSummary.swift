//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct DoseSummary: View {
    let type: String
    let value: String
    let unit: String
    
    
    var body: some View {
        HStack {
            Text("\(type) Dosage:")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            HStack {
                Text(value)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                Text(unit)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}


#Preview {
    DoseSummary(type: "Current", value: "43", unit: "mg")
}
