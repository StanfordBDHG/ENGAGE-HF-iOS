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
    
    
    private var units: (hkUnit: HKUnit, display: String) {
        viewModel.getUnits(data: data)
    }
    
    private var graphData: [VitalMeasurement] {
        viewModel.processData(data: data, units: units.hkUnit)
    }
    
    
    var body: some View {
        VitalsGraph(
            data: graphData,
            dateRange: dateRange,
            dateResolution: dateResolution,
            displayUnit: units.display
        )
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
