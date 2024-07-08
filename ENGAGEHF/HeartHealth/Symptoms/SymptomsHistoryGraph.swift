//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Charts
import SwiftUI


struct SymptomsHistoryGraph: View {
    var data: [SymptomScore]
    var symptomType: SymptomsType
    
    var startDate: Date
    var endDate: Date
    
    
    var body: some View {
        Chart(data) { score in
            LineMark(
                x: .value("Date", score.date, unit: .day),
                y: .value("Score", score[keyPath: symptomType.symptomScoreKeyMap])
            )
            .lineStyle(StrokeStyle(lineWidth: 1, dash: [2]))
            
            PointMark(
                x: .value("Date", score.date, unit: .day),
                y: .value("Score", score[keyPath: symptomType.symptomScoreKeyMap])
            )
        }
        .chartYScale(domain: 0...100)
        .chartXScale(domain: startDate...endDate)
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
        .frame(maxWidth: .infinity, idealHeight: 200)
        .padding(.vertical, 8)
    }
}


#Preview {
    struct SymptomsHistoryGraphPreviewWrapper: View {
        @Environment(VitalsManager.self) private var vitalsManager
        var symptomType: SymptomsType
        
        
        // For now, take the measurements from the last month
        private var dateRangeStart: Date {
            Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? .now
        }

        private var dateRangeEnd: Date {
            .now
        }
        
        private var data: [SymptomScore] {
            vitalsManager.symptomHistory
                .filter {
                    (dateRangeStart...dateRangeEnd).contains($0.date)
                }
        }
        
        
        var body: some View {
            SymptomsHistoryGraph(
                data: data,
                symptomType: symptomType,
                startDate: dateRangeStart,
                endDate: dateRangeEnd
            )
        }
    }
    
    
    return SymptomsHistoryGraphPreviewWrapper(symptomType: .overall)
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}
