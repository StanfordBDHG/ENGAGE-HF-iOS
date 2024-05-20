//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import BluetoothServices
@_spi(TestingSupport) import SpeziBluetooth
import SpeziViews
import SwiftUI


private struct MeasurementRecordedViewPreviewWrapper: View {
    @Environment(MeasurementManager.self) private var measurementManager
    @State private var viewState: ViewState = .idle
    
    
    var body: some View {
        @Bindable var measurementManager = measurementManager
        
        Button("Mock Measurement") {
            measurementManager.loadMockMeasurement()
        }
            .sheet(isPresented: $measurementManager.showSheet) {
                MeasurementRecordedView()
                    .presentationDetents([.fraction(0.4)])
            }
    }
}


struct MeasurementRecordedView: View {
    @State var viewState = ViewState.idle
    
    
    var body: some View {
        VStack {
            CloseButtonLayer(viewState: $viewState)
            Spacer()
            MeasurementLayer()
            Spacer()
            ConfirmMeasurementButton(viewState: $viewState)
                .padding()
        }
            .interactiveDismissDisabled(viewState != .idle)
    }
}


#Preview {
    MeasurementRecordedViewPreviewWrapper()
        .previewWith(standard: ENGAGEHFStandard()) {
            MeasurementManager()
        }
}
