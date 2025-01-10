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
    let data: SeriesDictionary
    let options: VitalsGraphOptions
    
    @State private var viewModel = ViewModel()
    
    
    var body: some View {
        VitalsGraphContent(
            viewModel: viewModel,
            targetValue: viewModel.targetValue
        )
            // Default styling
            .modifier(DefaultChartStyle(viewModel: viewModel))
            // Overlay for tracking gestures
            .modifier(GestureOverlay(viewModel: viewModel))
            // State change modifiers to listen for updates to the environment and handle errors
            .onChange(of: options) { viewModel.processData(data, options: options) }
            .task { viewModel.processData(data, options: options) }
            .viewStateAlert(state: $viewModel.viewState)
    }
    
     
    init(data: SeriesDictionary, options: VitalsGraphOptions = .defaultOptions) {
        self.data = data
        self.options = options
    }
}


#Preview {
    VitalsGraph(
        data: [:],
        options: .defaultOptions
    )
}
