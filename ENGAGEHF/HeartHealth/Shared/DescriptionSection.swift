//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct DescriptionSection: View {
    var localizedExplanation: String
    var quantityName: String
    
    
    var body: some View {
        Section(
            content: {
                Text(localizedExplanation)
            },
            header: {
                Text("About \(quantityName)")
                    .font(.title3.bold())
            }
        )
    }
}


#Preview {
    DescriptionSection(localizedExplanation: "Symptoms Explanation", quantityName: "Overall Score")
}
