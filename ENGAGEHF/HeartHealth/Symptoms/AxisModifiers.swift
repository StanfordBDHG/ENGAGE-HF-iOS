//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Charts
import SwiftUI


struct DizzinessYAxisModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .chartYScale(domain: 0...5)
            .chartYAxis {
                AxisMarks(values: .automatic(desiredCount: 5))
            }
    }
}

struct PercentageYAxisModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .chartYScale(domain: 0...100)
            .chartYAxis {
                AxisMarks(
                    values: [0, 50, 100]
                ) {
                    AxisValueLabel(format: Decimal.FormatStyle.Percent.percent.scale(1))
                }
                
                AxisMarks(
                    values: [0, 25, 50, 75, 100]
                ) {
                    AxisGridLine()
                }
            }
    }
}
