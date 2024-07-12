//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct DescriptionSection: View {
    var explanationKey: String
    
    
    var body: some View {
        Section(
            content: {
                Text(LocalizedStringKey(explanationKey))
            },
            header: {
                Text("Description")
                    .font(.title3.bold())
            }
        )
    }
}


#Preview {
    DescriptionSection(explanationKey: "symptomsOverall")
}
