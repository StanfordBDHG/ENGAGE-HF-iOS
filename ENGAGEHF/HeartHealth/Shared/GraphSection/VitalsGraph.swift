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
    var data: [String: [VitalMeasurement]]
    var options: VitalsGraphOptions = .defaultOptions
    
    @State private var viewModel = ViewModel()
    
    
    var body: some View {
        ChartContent(
            viewModel: viewModel,
            dateUnit: viewModel.dateUnit,
            quantityUnit: viewModel.localizedUnitString
        )
            // Default styling
            .modifier(DefaultChartStyle(viewModel: viewModel, dateRange: viewModel.dateRange))
            // Overlay for tracking gestures
            .modifier(GestureOverlay(viewModel: viewModel))
            // State change modifiers to listen for updates to the environment and handle errors
            .onChange(of: data) {
                viewModel.processData(data, options: options)
            }
            .onChange(of: options) {
                viewModel.processData(data, options: options)
            }
            .onAppear {
                viewModel.processData(data, options: options)
            }
            .viewStateAlert(state: $viewModel.viewState)
    }
}


#Preview {
    VitalsGraph(
        data: [:],
        options: .defaultOptions
    )
}
