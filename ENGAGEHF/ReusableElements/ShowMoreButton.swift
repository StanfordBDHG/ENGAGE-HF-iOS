//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct ShowMoreButton: View {
    private var labelText: String {
        isExpanded ? "Show less" : "Show more"
    }
    
    @Binding var isExpanded: Bool
    
    
    var body: some View {
        Button(
            action: {
                isExpanded.toggle()
            },
            label: {
                Text(labelText)
                    .foregroundStyle(.accent)
                    .font(.footnote)
            }
        )
    }
}

#Preview {
    struct LearnMoreButtonPreviewWrapper: View {
        @State var isExpanded = false
        
        
        var body: some View {
            ShowMoreButton(isExpanded: $isExpanded)
        }
    }
    
    
    return LearnMoreButtonPreviewWrapper()
}
