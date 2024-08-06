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
            }
                .background(background)
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
