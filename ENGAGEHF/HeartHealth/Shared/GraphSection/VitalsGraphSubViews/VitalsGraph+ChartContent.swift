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
    struct ChartContent: View {
        let viewModel: ViewModel
        let dateUnit: Calendar.Component
        let quantityUnit: String

        private let intervalSummaryHeight: CGFloat = 70
        
        
        var body: some View {
            Chart {
                if let selection = viewModel.selection {
                    RuleMark(x: .value("Date", selection.interval.lowerBound, unit: dateUnit))
                        .foregroundStyle(Color(.lightGray).opacity(0.5))
                        .annotation(
                            position: .top,
                            overflowResolution: .init(x: .fit, y: .disabled)
                        ) {
                            IntervalSummary(
                                quantity: viewModel.selectionFormatter(selection.points.map { ($0.series, $0.value) }),
                                interval: selection.interval,
                                unit: quantityUnit,
                                averaged: selection.points.contains(where: { $0.count > 1 }),
                                idealHeight: intervalSummaryHeight,
                                accessibilityLabel: "Interval Summary"
                            )
                        }
                        .accessibilityIdentifier("Interval Selected: \(selection.interval.formatted())")
                }
                
                ForEach(viewModel.aggregatedData) { series in
                    ForEach(series.data) { point in
                        LineMark(
                            x: .value("Date", point.date, unit: dateUnit),
                            y: .value("Score", point.value)
                        )
                            .foregroundStyle(by: .value("Series", series.seriesName))
                        PointMark(
                            x: .value("Date", point.date, unit: dateUnit),
                            y: .value("Score", point.value)
                        )
                            .foregroundStyle(by: .value("Series", series.seriesName))
                    }
                }
            }
                .accessibilityIdentifier("Vitals Graph")
                .frame(maxWidth: .infinity, idealHeight: 200)
                .padding(.top, intervalSummaryHeight + 4)
                .overlay(alignment: .topLeading) {
                    if viewModel.selection == nil {
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
                    }
                }
        }
    }
}
