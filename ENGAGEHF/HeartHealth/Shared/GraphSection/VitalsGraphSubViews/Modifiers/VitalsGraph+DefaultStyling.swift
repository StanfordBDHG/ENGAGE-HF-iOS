//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Charts
import SwiftUI


extension VitalsGraph {
    struct DefaultChartStyle: ViewModifier {
        let viewModel: ViewModel
        let dateRange: ClosedRange<Date>
        
        
        func body(content: Content) -> some View {
            content
                .chartXScale(domain: dateRange)
                .chartXAxis {
                    AxisMarks(values: .automatic()) {
                        AxisGridLine()
                        AxisValueLabel()
                    }
                    // Add a solid vertical boundary line to the left half of the chart
                    AxisMarks(values: [dateRange.lowerBound]) {
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [0]))
                    }
                }
                .chartForegroundStyleScale(range: [Color.accentColor, Color.complement])
                .chartLegend(viewModel.aggregatedData.count > 1 ? .visible : .hidden)
        }
    }
}
