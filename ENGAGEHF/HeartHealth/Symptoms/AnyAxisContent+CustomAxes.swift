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
    
    // Dizziness scores range between 0 and 5, and each has a specific desired label.
    @AxisContentBuilder private static var dizzinessYAxisModifierBuilder: some AxisContent {
        AxisMarks(values: [0, 1, 2, 3, 4, 5]) { value in
            switch value.as(Int.self) {
            case 5:
                AxisValueLabel("Very Severe")
            case 4:
                AxisValueLabel("Severe")
            case 3:
                AxisValueLabel("Moderate")
            case 2:
                AxisValueLabel("Mild")
            case 1:
                AxisValueLabel("Minimal")
            case 0:
                AxisValueLabel("None")
            default:
                AxisValueLabel("")
            }
        }
        
        AxisMarks(
            values: [0, 1, 2, 3, 4, 5]
        ) {
            AxisGridLine()
        }
    }
    
    static var percentageYAxisModifier: AnyAxisContent {
        AnyAxisContent(percentageYAxisModifierBuilder)
    }
    
    
    static var dizzinessYAxisModifier: AnyAxisContent {
        AnyAxisContent(dizzinessYAxisModifierBuilder)
    }
}
