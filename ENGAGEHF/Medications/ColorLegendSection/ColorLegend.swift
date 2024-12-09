//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct ColorLegend: View {
    @State var isExpanded = true
    
    var body: some View {
        ExpandableSection(
            content: {
                VStack(alignment: .leading) {
                    ForEach(RecommendationStyle.allCases, id: \.self) {
                        ColorKeyEntryView(color: $0.color, interpretation: $0.localizedInterpretation)
                    }
                }
            },
            header: {
                Text("Legend")
                    .padding(.horizontal, -16)
            }
        )
    }
}


#Preview {
    List {
        ColorLegend()
    }
}
