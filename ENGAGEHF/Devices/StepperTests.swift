//
//  StepperTests.swift
//  ENGAGEHF
//
//  Created by Andreas Bauer on 20.06.24.
//

import SwiftUI

struct StepperTests: View {
    @State var index = 3
    var body: some View {
        Stepper("Page \(index + 1) of \(10)", value: $index, in: 0...(10 - 1), step: 1)
            .accessibilityValue("Page \(index + 1) of \(10)")
            .accessibilityLabel("Page")
    }
}

#Preview {
    StepperTests()
}
