//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct CapsuleStack: View {
    let gaugeWidth: CGFloat
    let gaugeHeight: CGFloat
    let progressWidth: CGFloat
    
    
    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .frame(height: gaugeHeight)
                .foregroundStyle(Color(.systemGray6))
            Capsule()
                .frame(width: progressWidth, height: gaugeHeight)
                .foregroundStyle(.accent)
        }
    }
}


#Preview {
    CapsuleStack(gaugeWidth: 50.0, gaugeHeight: 15, progressWidth: 40)
}
