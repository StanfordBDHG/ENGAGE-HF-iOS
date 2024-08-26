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
        let target: SeriesTarget?
        
        
        var body: some View {
            HStack(alignment: .lastTextBaseline) {
                IntervalSummary(
                    quantity: viewModel.selectionFormatter(viewModel.aggregatedData.map { ($0.seriesName, $0.average ) }),
                    interval: DateInterval(
                        start: viewModel.dateRange.lowerBound,
                        end: viewModel.dateRange.upperBound
                    ).asAdjustedRange(using: viewModel.calendar) ?? Date()..<Date(),
                    unit: quantityUnit,
                    averaged: true,
                    idealHeight: intervalSummaryHeight,
                    accessibilityLabel: "Overall Summary"
                )
                Spacer()
                if let target {
                    VStack(alignment: .trailing) {
                        Text("Dry Weight")
                            .bold()
                        Text(target.value.asString(maximumFractionDigits: 1))
                        Text(target.unit)
                        Text(target.date.formatted(date: .abbreviated, time: .omitted))
                    }
                }
            }
        }
    }
}
