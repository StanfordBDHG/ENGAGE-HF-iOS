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
    
    private var data: [String: [VitalMeasurement]] {
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
            granularity: .day,
            localizedUnitString: "%",
            selectionFormatter: { selected in
                String(format: "%.1f", selected.first(where: { $0.0 == KnownVitalsSeries.symptomScore.rawValue })?.1 ?? "---")
            }
        )
    }
    
    
    var body: some View {
        Section(
            content: {
                let graphData = data
                if !graphData.isEmpty {
                    let graph = VitalsGraph(data: graphData, options: options)
                    if symptomsType == .dizziness {
                        graph.modifier(DizzinessYAxisModifier())
                    } else {
                        graph.modifier(PercentageYAxisModifier())
                    }
                } else {
                    Text(symptomsType.localizedEmptyHistoryWarning)
                        .font(.caption)
                        .accessibilityLabel("Empty Symptoms Graph")
                }
            },
            header: {
                SymptomsPicker(symptomsType: $symptomsType)
                    .padding(.vertical, 5)
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
