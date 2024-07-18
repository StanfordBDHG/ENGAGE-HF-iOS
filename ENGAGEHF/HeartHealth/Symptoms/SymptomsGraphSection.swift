//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Charts
import SwiftUI


struct SymptomsGraphSection: View {
    private struct YAxisModifier: ViewModifier {
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
    
    
    @Binding var symptomsType: SymptomsType
    
    @Environment(VitalsManager.self) private var vitalsManager
    private let resolution: DateGranularity = .weekly
    
    
    private var dateRange: ClosedRange<Date> {
        resolution.getDateRange(endDate: .now)
    }
    
    private var data: [VitalMeasurement] {
        vitalsManager.symptomHistory.map { score in
            VitalMeasurement(
                date: score.date,
                value: score[keyPath: symptomsType.symptomScoreKeyMap],
                type: symptomsType.fullName
            )
        }.filter { dateRange.contains($0.date) }
    }
    
    
    var body: some View {
        Section(
            content: {
                if !data.isEmpty {
                    VitalsGraph(
                        data: data,
                        dateRange: dateRange,
                        dateResolution: .day,
                        displayUnit: "%",
                        chartModifier: AnyModifier(YAxisModifier())
                    )
                } else {
                    Text("No recent symptom scores available.")
                        .font(.caption)
                }
            },
            header: {
                SymptomsPicker(symptomsType: $symptomsType)
            }
        )
    }
}


#Preview {
    SymptomsGraphSection(symptomsType: .constant(.overall))
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}
