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
    private let annotationHeight: CGFloat = 70
    
    
    var body: some View {
        ChartContent(
            viewModel: viewModel,
            dateUnit: dateResolution,
            quantityUnit: displayUnit,
            intervalSummaryHeight: annotationHeight
        )
            // Default + custom chart modifiers for styling
            .modifier(DefaultChartStyle(viewModel: viewModel, dateRange: dateRange))
            .modifier(chartModifier ?? AnyModifier(EmptyModifier()))
            .frame(maxWidth: .infinity, idealHeight: 200)
            .padding(.top, annotationHeight + 4)
            // Overlay modifiers to present detailed point information
            .modifier(
                SummaryOverlay(
                    viewModel: viewModel,
                    dateRange: dateRange,
                    annotationHeight: annotationHeight,
                    displayUnit: displayUnit
                )
            )
            .modifier(GestureOverlay(viewModel: viewModel))
            // State change modifiers to listen for updates to the environment and handle errors
            .onChange(of: data) {
                viewModel.processData(data, dateRange: dateRange, dateUnit: dateResolution)
            }
            .onChange(of: dateResolution) {
                viewModel.processData(data, dateRange: dateRange, dateUnit: dateResolution)
            }
            .onAppear {
                viewModel.processData(data, dateRange: dateRange, dateUnit: dateResolution)
            }
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
