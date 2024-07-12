//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Charts
import SwiftUI

struct SymptomsGraph: View {
    var data: [SymptomScore]
    var granularity: DateGranularity
    var symptomType: SymptomsType
    
    
    private var dateDomain: DateInterval {
        do {
            return try granularity.getDateInterval(endDate: .now)
        } catch {
            return DateInterval(start: .now, end: .now)
        }
    }
    
    
    var body: some View {
        Chart(data) { score in
            LineMark(
                x: .value("Date", score.date, unit: granularity.intervalComponent),
                y: .value("Score", score[keyPath: symptomType.symptomScoreKeyMap])
            )
            .lineStyle(StrokeStyle(lineWidth: 1, dash: [2]))
            
            PointMark(
                x: .value("Date", score.date, unit: granularity.intervalComponent),
                y: .value("Score", score[keyPath: symptomType.symptomScoreKeyMap])
            )
        }
        .chartYScale(domain: 0...100)
        .chartXScale(domain: dateDomain.start...dateDomain.end)
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
    SymptomsGraph(data: [], granularity: .weekly, symptomType: .overall)
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}
