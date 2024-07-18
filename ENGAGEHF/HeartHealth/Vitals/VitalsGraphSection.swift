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
    
    private var graphData: [HKSample] {
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
                if !graphData.isEmpty {
                    HKSampleGraph(
                        data: graphData,
                        dateRange: dateRange,
                        dateResolution: granularity.defaultDateUnit
                    )
                } else {
                    Text("No recent \(vitalsType.description) available.")
                        .font(.caption)
                }
            },
            header: {
                HStack {
                    Text(vitalsType.description)
                    Spacer()
                    ResolutionPicker(selection: $granularity)
                }
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
