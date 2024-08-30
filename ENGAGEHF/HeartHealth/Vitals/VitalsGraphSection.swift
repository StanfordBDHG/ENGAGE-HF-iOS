//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import SpeziViews
import SwiftUI


struct VitalsGraphSection: View {
    var vitalsType: VitalsType
    
    @Environment(VitalsManager.self) private var vitalsManager
    @State private var granularity: DateGranularity = .daily
    
    
    private var dateRange: ClosedRange<Date> {
        granularity.getDateRange(endDate: .now)
    }
    
    @MainActor private var graphData: [HKSample] {
        let unfilteredData: [HKSample] = switch vitalsType {
        case .weight: vitalsManager.weightHistory
        case .heartRate: vitalsManager.heartRateHistory
        case .bloodPressure: vitalsManager.bloodPressureHistory
        }
        
        return unfilteredData.filter { dateRange.contains($0.startDate) }
    }
    
    
    var body: some View {
        Section(
            content: {
                let data = graphData
                if !data.isEmpty {
                    HKSampleGraph(
                        data: data,
                        dateRange: dateRange,
                        dateResolution: granularity.defaultDateUnit,
                        targetValue: vitalsType == .weight ? vitalsManager.latestDryWeight : nil
                    )
                } else {
                    Text(vitalsType.localizedEmptyHistoryWarning)
                        .font(.caption)
                        .accessibilityLabel("Empty \(vitalsType.description) Graph")
                }
            },
            header: {
                HStack {
                    Text(vitalsType.description)
                        .font(.title3.bold())
                    Spacer()
                    ResolutionPicker(selection: $granularity)
                }
                    .padding(.horizontal, -16)
            }
        )
    }
}


#Preview {
    VitalsGraphSection(vitalsType: .weight)
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}
