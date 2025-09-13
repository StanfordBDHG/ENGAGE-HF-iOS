//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Charts
import SwiftUI
import SpeziViews


extension AnyAxisContent {
    @AxisContentBuilder private static var percentageYAxisModifierBuilder: some AxisContent {
        AxisMarks(values: [0, 50, 100]) {
            AxisValueLabel(format: Decimal.FormatStyle.Percent.percent.scale(1))
        }
        AxisMarks(values: [0, 25, 50, 75, 100]) {
            AxisGridLine()
        }
    }
    
    // Dizziness scores range between 0 and 5, and each has a specific desired label.
    @AxisContentBuilder private static var dizzinessYAxisModifierBuilder: some AxisContent {
        AxisMarks(values: [0, 1, 2, 3, 4, 5]) { value in
            if let doubleValue = value.as(Double.self),
               let localizedDizzinessScore = SymptomScore.mapLocalizedDizzinessScore(doubleValue) {
                AxisValueLabel(localizedDizzinessScore.localizedString())
            } else {
                AxisValueLabel("")
            }
        }
        AxisMarks(values: [0, 1, 2, 3, 4, 5]) {
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
