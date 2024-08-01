//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct ShowMoreButton: View {
    @Binding var isExpanded: Bool
    
    
    var body: some View {
        Button(
            action: {
                withAnimation {
                    isExpanded.toggle()
                }
            },
            label: {
                Text(isExpanded ? "Show less" : "Show more")
                    .foregroundStyle(.accent)
                    .font(.footnote)
                    .animation(nil, value: isExpanded)
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
