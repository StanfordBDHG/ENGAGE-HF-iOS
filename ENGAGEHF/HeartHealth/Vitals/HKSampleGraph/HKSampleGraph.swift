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


struct HKSampleGraph: View {
    var data: [HKSample]
    var dateRange: ClosedRange<Date>
    var dateResolution: Calendar.Component
    var targetValue: HKSample?
    
    @State private var viewModel = ViewModel()
    
    
    var body: some View {
        VitalsGraph(
            data: viewModel.seriesData,
            options: VitalsGraphOptions(
                dateRange: dateRange,
                targetValue: viewModel.targetValue,
                granularity: dateResolution,
                localizedUnitString: viewModel.displayUnit,
                selectionFormatter: viewModel.formatter
            )
        )
            .onChange(of: data) { viewModel.processData(data: data) }
            .onChange(of: targetValue) { viewModel.processTargetValue(targetValue) }
            .task {
                viewModel.processData(data: data)
                viewModel.processTargetValue(targetValue)
            }
            .viewStateAlert(state: $viewModel.viewState)
    }
}


#Preview {
    HKSampleGraph(
        data: [],
        dateRange: Date()...Date(),
        dateResolution: .day
    )
}
