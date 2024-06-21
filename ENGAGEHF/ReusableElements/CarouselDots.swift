//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct CarouselDots: View {
    private static let hStackSpacing: CGFloat = 10
    private static let circleDiameter: CGFloat = 7
    private static let padding: CGFloat = 10

    private let count: Int
    @Binding private var selectedIndex: Int

    @State private var isDragging = false

    private var pageNumber: Binding<Int> {
        .init {
            selectedIndex + 1
        } set: { newValue in
            selectedIndex = newValue - 1
        }
    }

    private var totalWidth: CGFloat {
        CGFloat(count) * Self.circleDiameter + CGFloat((count - 1)) * Self.hStackSpacing + 2 * Self.padding
    }

    var body: some View {
        HStack(spacing: Self.hStackSpacing) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .frame(width: Self.circleDiameter, height: Self.circleDiameter)
                    .foregroundStyle(index == selectedIndex ? .primary : .tertiary)
                    .onTapGesture {
                        withAnimation {
                            selectedIndex = index
                        }
                    }
            }
        }
            .padding(Self.padding)
            .background {
                // make sure voice hover highlighter has round corners
                RoundedRectangle(cornerSize: CGSize(width: 5, height: 5))
                    .foregroundColor(Color(uiColor: isDragging ? .systemFill : .systemBackground))
            }
            .gesture(dragGesture)
            .accessibilityRepresentation {
                Stepper("Page", value: pageNumber, in: 1...count, step: 1)
                    .accessibilityValue("Page \(pageNumber.wrappedValue) of \(count)")
            }
    }


    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 2)
            .onChanged { value in
                isDragging = true
                updateIndexBasedOnDrag(value.location)
                print("location: \(value.location)")
            }
            .onEnded { value in
                isDragging = false
                print("ended: \(value)")
                updateIndexBasedOnDrag(value.location)
            }
    }


    init(count: Int, selectedIndex: Binding<Int>) {
        self.count = count
        self._selectedIndex = selectedIndex
    }


    private func updateIndexBasedOnDrag(_ location: CGPoint) {
        guard count > 0 else { // swiftlint:disable:this empty_count
            return // swiftlint false positive
        }

        let pointWidths = totalWidth / CGFloat(count)
        let relativePosition = location.x

        let index = max(0, min(count - 1, Int(relativePosition / pointWidths)))
        selectedIndex = index // TODO: this should not animate?
    }
}


#if DEBUG
#Preview {
    CarouselDots(count: 3, selectedIndex: .constant(0))
}
#endif
