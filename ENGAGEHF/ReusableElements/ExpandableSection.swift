//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// Creates a `Section` whose generic parameters allow for the `init(isExpanded:content:header:)` initializer
/// (`Parent` conforms to `View`, `Content` conforms to `View`, and `Footer` is the `EmptyView`).
///
/// Returns a `Section` that toggles expansion with animation when the user taps the header.
struct ExpandableSection<Parent: View, Content: View>: View {
    private let content: () -> Content
    private let header: () -> Parent
    
    @State private var isExpanded: Bool
    
    
    var body: some View {
        Section(
            isExpanded: $isExpanded,
            content: content,
            header: {
                HStack {
                    header()
                    Spacer()
                    Image(systemName: "chevron.right")
                        .accessibilityLabel("Expansion Button")
                        .foregroundStyle(.accent)
                        .font(.headline)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                    .asButton {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    }
            }
        )
    }
    
    
    init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder header: @escaping () -> Parent,
        expandByDefault: Bool = true
    ) {
        self.content = content
        self.header = header
        self.isExpanded = expandByDefault
    }
}


extension ExpandableSection where Parent == Text {
    // periphery:ignore - kept for potentially being useful in the future
    init(
        _ header: String,
        @ViewBuilder content: @escaping () -> Content,
        expandByDefault: Bool = true
    ) {
        self.header = { Text(header) }
        self.content = content
        self.isExpanded = expandByDefault
    }
}


#Preview("ViewBuilder Header") {
    List {
        ExpandableSection(
            content: {
                Text("Hello, world!")
            },
            header: {
                Text("Expandable")
            }
        )
    }
}

#Preview("String Header") {
    List {
        ExpandableSection("Expandable") {
            Text("Hello, world!")
        }
    }
}
