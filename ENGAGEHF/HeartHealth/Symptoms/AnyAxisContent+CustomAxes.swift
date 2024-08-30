//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Charts
import SwiftUI

extension AnyAxisContent {
    @AxisContentBuilder private static var percentageYAxisModifierBuilder: some AxisContent {
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
    
    static var percentageYAxisModifier: AnyAxisContent {
        AnyAxisContent(percentageYAxisModifierBuilder)
    }
    
    
    static var dizzinessYAxisModifier: AnyAxisContent {
        AnyAxisContent(AxisMarks(values: .automatic(desiredCount: 5)))
    }
}
