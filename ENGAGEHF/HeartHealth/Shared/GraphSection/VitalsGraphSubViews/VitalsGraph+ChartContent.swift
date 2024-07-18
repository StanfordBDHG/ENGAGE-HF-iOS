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
        var viewModel: ViewModel
        var dateUnit: Calendar.Component
        var quantityUnit: String
        var intervalSummaryHeight: CGFloat
        
        
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
                                quantity: getDisplayQuantity(points: selection.points),
                                interval: selection.interval,
                                unit: quantityUnit,
                                averaged: selection.points.contains(where: { $0.count > 1 }),
                                idealHeight: intervalSummaryHeight,
                                accessibilityLabel: "Interval Summary"
                            )
                        }
                }
                
                ForEach(viewModel.aggregatedData) { score in
                    LineMark(
                        x: .value("Date", score.date, unit: dateUnit),
                        y: .value("Score", score.value)
                    )
                        .foregroundStyle(by: .value("VitalType", score.type))
                    PointMark(
                        x: .value("Date", score.date, unit: dateUnit),
                        y: .value("Score", score.value)
                    )
                        .foregroundStyle(by: .value("VitalType", score.type))
                }
            }
        }
        
        
        private func getDisplayQuantity(points: [AggregatedMeasurement]) -> String {
            switch points.count {
            case 1: return String(format: "%.1f", points.first!.value)
            case 2:
                let systolic: AggregatedMeasurement? = points.first(
                    where: { point in
                        point.type == "\(KnownSeries.bloodPressureSystolic)"
                    }
                )
                let diastolic: AggregatedMeasurement? = points.first(
                    where: { point in
                        point.type == "\(KnownSeries.bloodPressureDiastolic)"
                    }
                )
                guard let systolic, let diastolic else {
                    return "---"
                }
                return "\(Int(systolic.value))/\(Int(diastolic.value))"
            default: return "---"
            }
        }
    }
}
