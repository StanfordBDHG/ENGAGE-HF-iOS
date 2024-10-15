//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct ExpandableListCard<Label: View, Content: View>: View {
    let label: () -> Label
    let content: () -> Content
    
    @State private var isExpanded = false
    
    
    var body: some View {
        VStack {
            HStack {
                label()
                Spacer()
                Image(systemName: "chevron.right")
                    .accessibilityLabel("Expansion Button")
                    .foregroundStyle(.accent)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .animation(nil, value: isExpanded)
            }
                .asButton { isExpanded.toggle() }
            
            if isExpanded {
                Divider()
                content()
            }
        }
    }
    
    
    init(
        @ViewBuilder label: @escaping () -> Label,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.label = label
        self.content = content
    }
}


extension List {
    func expandableCardListStyle() -> some View {
        self
            .listRowSeparator(.hidden)
            .listRowSpacing(8)
    }
}
