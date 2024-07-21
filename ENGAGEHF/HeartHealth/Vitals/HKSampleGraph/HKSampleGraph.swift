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
    
    @State private var viewModel = ViewModel()
    
    
    var body: some View {
        VitalsGraph(
            data: viewModel.seriesData,
            options: VitalsGraphOptions(
                dateRange: dateRange,
                granularity: dateResolution,
                localizedUnitString: viewModel.displayUnit,
                selectionFormatter: viewModel.formatter
            )
        )
            .onChange(of: data) { viewModel.processData(data: data) }
            .onAppear { viewModel.processData(data: data) }
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
