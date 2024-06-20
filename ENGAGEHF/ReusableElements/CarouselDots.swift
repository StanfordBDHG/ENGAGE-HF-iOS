//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct CarouselDots: View {
    private let count: Int
    @Binding private var selectedIndex: Int

    private var pageNumber: Binding<Int> {
        .init {
            selectedIndex + 1
        } set: { newValue in
            selectedIndex = newValue - 1
        }
    }

    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .frame(width: 7, height: 7)
                    .foregroundStyle(index == selectedIndex ? .primary : .tertiary)
                    .onTapGesture {
                        withAnimation {
                            selectedIndex = index // TODO: drag slider
                        }
                    }
            }
        }
        .padding(10)
        .background {
            // make sure voice hover highlighter has round corners
            RoundedRectangle(cornerSize: CGSize(width: 5, height: 5))
                .foregroundColor(Color(uiColor: .systemBackground))
        }
        .accessibilityRepresentation {
            Stepper("Page", value: pageNumber, in: 1...count, step: 1)
                .accessibilityValue("Page \(pageNumber.wrappedValue) of \(count)")
        }
    }

    init(count: Int, selectedIndex: Binding<Int>) {
        self.count = count
        self._selectedIndex = selectedIndex
    }
}


#if DEBUG
#Preview {
    CarouselDots(count: 3, selectedIndex: .constant(0))
}
#endif
