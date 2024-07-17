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
        
        
        var body: some View {
            Chart {
//                if let (interval, value) = viewModel.selectedPoint {
//                    RuleMark(x: .value("Date", interval.start, unit: dateUnit))
//                        .foregroundStyle(Color(.lightGray).opacity(0.5))
//                        .annotation(
//                            position: .top,
//                            overflowResolution: .init(x: .fit, y: .disabled)
//                        ) {
//                            PointDetails(
//                                interval: interval,
//                                value: String(format: "%.1f", value),
//                                unit: displayUnit,
//                                idealHeight: annotationHeight
//                            )
//                        }
//                }
                
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
    }
}
