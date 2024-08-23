//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct CapsuleStack: View {
    let gaugeHeight: CGFloat
    let progress: CGFloat
    
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .foregroundStyle(Color(.systemGray6))
                Capsule()
                    .frame(width: progress * geometry.size.width)
                    .foregroundStyle(.accent)
            }
        }
            .frame(height: gaugeHeight)
    }
}


#Preview {
    CapsuleStack(gaugeHeight: 15, progress: 0.5)
}
