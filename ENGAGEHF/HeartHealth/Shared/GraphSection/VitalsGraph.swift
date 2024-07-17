//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Charts
import SpeziViews
import SwiftUI

struct VitalsGraph: View {
    var data: [VitalMeasurement]
    var dateRange: ClosedRange<Date>
    var dateResolution: Calendar.Component
    var displayUnit: String
    var chartModifier: AnyModifier?
    
    @State private var viewModel = ViewModel()
    private let annotationHeight: CGFloat = 6
    
    
    var body: some View {
        VStack {
            ChartContent(viewModel: viewModel, dateUnit: dateResolution)
                .modifier(DefaultChartStyle(viewModel: viewModel, dateRange: dateRange))
                .modifier(chartModifier ?? AnyModifier(EmptyModifier()))
                .modifier(GestureOverlay(viewModel: viewModel))
        }
        // Make sure to reset selected interval when, for example, a different symptom score type is selected
        .onChange(of: data) {
            viewModel.processData(data, dateRange: dateRange, dateUnit: dateResolution)
        }
        .onChange(of: dateResolution) {
            viewModel.processData(data, dateRange: dateRange, dateUnit: dateResolution)
        }
        .onAppear {
            viewModel.processData(data, dateRange: dateRange, dateUnit: dateResolution)
        }
        .frame(maxWidth: .infinity, idealHeight: 200)
        .padding(.top, annotationHeight + 4)
        .viewStateAlert(state: $viewModel.viewState)
    }
}


#Preview {
    VitalsGraph(
        data: [],
        dateRange: Date()...Date(),
        dateResolution: .day,
        displayUnit: ""
    )
}
