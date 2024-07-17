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
    
    
    private var graphData: [HKSample] {
        switch vitalsType {
        case .weight: vitalsManager.weightHistory
        case .heartRate: vitalsManager.heartRateHistory
        case .bloodPressure: vitalsManager.bloodPressureHistory
        }
    }
    
    
    var body: some View {
        Section(
            content: {
                HKSampleGraph(
                    data: graphData,
                    dateRange: granularity.getDateRange(endDate: .now),
                    dateResolution: granularity.defaultDateUnit
                )
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
