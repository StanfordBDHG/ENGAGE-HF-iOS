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
    @Binding var symptomsType: SymptomsType
    
    @Environment(VitalsManager.self) private var vitalsManager
    private let resolution: DateGranularity = .weekly
    
    
    private var dateRange: ClosedRange<Date> {
        resolution.getDateRange(endDate: .now)
    }
    
    @MainActor private var graphData: [String: [VitalMeasurement]] {
        let ungroupedData = vitalsManager.symptomHistory
            .compactMap { score -> VitalMeasurement? in
                guard let value = score[keyPath: symptomsType.symptomScoreKeyMap] else {
                    return nil
                }
                
                return VitalMeasurement(
                    date: score.date,
                    value: value,
                    type: KnownVitalsSeries.symptomScore.rawValue
                )
            }
            .filter { dateRange.contains($0.date) }
        
        return Dictionary(grouping: ungroupedData) { $0.type }
    }
    
    private var options: VitalsGraphOptions {
        VitalsGraphOptions(
            dateRange: resolution.getDateRange(endDate: .now),
            valueRange: symptomsType == .dizziness ? 0...5 : 0...100,
            granularity: .day,
            localizedUnitString: symptomsType == .dizziness ? "" : "%",
            selectionFormatter: { selected in
                let matchingSeriesValue = selected.first(where: { $0.0 == KnownVitalsSeries.symptomScore.rawValue })?.1
                return matchingSeriesValue?.asString(minimumFractionDigits: 0, maximumFractionDigits: 1) ?? "No Data"
            }
        )
    }
    
    
    var body: some View {
        Section(
            content: {
                VitalsGraph(data: graphData, options: options)
                    .environment(\.customChartYAxis, symptomsType == .dizziness ? .dizzinessYAxisModifier : .percentageYAxisModifier )
            },
            header: {
                SymptomsPicker(symptomsType: $symptomsType)
                    .padding(.vertical, 5)
                    .padding(.leading, -16)
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
