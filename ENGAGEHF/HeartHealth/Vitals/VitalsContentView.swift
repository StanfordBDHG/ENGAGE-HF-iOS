//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct VitalsContentView: View {
    private var vitalsType: VitalsType
    
    
    var body: some View {
        Text(vitalsType.description)
            .padding()
    }
    
    
    init(for vitals: VitalsType) {
        self.vitalsType = vitals
    }
}


#Preview {
    VitalsContentView(for: .weight)
}
