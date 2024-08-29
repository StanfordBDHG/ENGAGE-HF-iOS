//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


extension VitalsGraph {
    struct GraphHeader: View {
        let viewModel: ViewModel
        let quantityUnit: String
        let intervalSummaryHeight: CGFloat
        
        
        var body: some View {
            IntervalSummary(
                quantity: viewModel.selectionFormatter(viewModel.aggregatedData.map { ($0.seriesName, $0.average) }),
                interval: DateInterval(
                    start: viewModel.dateRange.lowerBound,
                    end: viewModel.dateRange.upperBound
                ).asAdjustedRange(using: viewModel.calendar) ?? Date()..<Date(),
                unit: quantityUnit,
                averaged: viewModel.totalDataPoints > 1,
                idealHeight: intervalSummaryHeight,
                accessibilityLabel: "Overall Summary"
            )
        }
    }
}
