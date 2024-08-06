//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


private struct TextSizePreference: PreferenceKey {
    static let defaultValue: CGSize = .zero
    
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}


/// Text field that expands to the minimum size that fits the text, until there is no room to expand.
/// Then, the field becomes scrollable, and the text extends beyond the visible portion.
///
/// Note: Modifiers applied to a ScrollableText instance are applied to the GeometryReader, which
/// greedily expands to fill all the available space. This can cause undesired behavior if, for example,
/// an overlay or border is applied to the ScrollableText as these will extend beyond the text field.
struct ScrollableText<Background: View>: View {
    private let text: String
    private let background: Background
    
    @State private var textHeight: CGFloat = 0
    
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                Text(text)
                    .padding()
                    .readSize(TextSizePreference.self) {
                        textHeight = $0.height
                    }
                    .frame(width: geometry.size.width, alignment: .leading)
                    .accessibilityIdentifier("Scrollable Text")
            }
                .background(background)
                .scrollBounceBehavior(.basedOnSize)
                .frame(height: min(textHeight, geometry.size.height))
        }
    }
    
    
    init(_ text: String, @ViewBuilder background: () -> Background = { EmptyView() }) {
        self.text = text
        self.background = background()
    }
}


#Preview {
    ScrollableText(
        """
        Long description of a complex topic.
        """
    )
}
