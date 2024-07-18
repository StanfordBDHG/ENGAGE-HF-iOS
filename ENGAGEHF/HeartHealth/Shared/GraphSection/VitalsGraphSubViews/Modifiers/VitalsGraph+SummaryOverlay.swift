//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


extension VitalsGraph {
    struct SummaryOverlay: ViewModifier {
        var viewModel: ViewModel
        var dateRange: ClosedRange<Date>
        var annotationHeight: CGFloat
        var displayUnit: String
        
        
        func body(content: Content) -> some View {
            content
                .overlay(alignment: .topLeading) {
                    if viewModel.selection == nil {
                        IntervalSummary(
                            quantity: getDisplayQuantity(for: viewModel.overallAverages),
                            interval: adjustDateRange(dateRange),
                            unit: displayUnit,
                            averaged: true,
                            idealHeight: annotationHeight,
                            accessibilityLabel: "Overall Summary"
                        )
                    }
                }
        }
        
        
        private func getDisplayQuantity(for averages: [String: Double]) -> String {
            switch averages.count {
            case 1: return String(format: "%.1f", averages.values.first!)
            case 2:
                let systolic: Double? = averages.first(
                    where: { series, _ in
                        series == "\(KnownSeries.bloodPressureSystolic)"
                    }
                )?.value
                let diastolic: Double? = averages.first(
                    where: { series, _ in
                        series == "\(KnownSeries.bloodPressureDiastolic)"
                    }
                )?.value
                
                guard let systolic, let diastolic else {
                    return "---"
                }
                return "\(Int(systolic))/\(Int(diastolic))"
            default: return "---"
            }
        }
        
        private func adjustDateRange(_ closedRange: ClosedRange<Date>) -> Range<Date> {
            let calendar = Calendar.current
            
            let start = closedRange.lowerBound
            guard let adjustedEnd = calendar.date(byAdding: .second, value: -1, to: closedRange.upperBound) else {
                return start ..< start
            }
            
            return start..<adjustedEnd
        }
    }
}
