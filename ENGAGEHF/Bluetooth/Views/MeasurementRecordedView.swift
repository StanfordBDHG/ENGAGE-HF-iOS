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


struct MeasurementRecordedView: View {
    private var dynamicDetente: PresentationDetent {
        switch dynamicTypesize {
        case .xSmall, .small:
            return .fraction(0.35)
        case .medium, .large:
            return .fraction(0.45)
        case .xLarge, .xxLarge, .xxxLarge:
            return .fraction(0.65)
        case .accessibility1, .accessibility2, .accessibility3, .accessibility4, .accessibility5:
            return .large
        default:
            return .fraction(0.45)
        }
    }
    

    @Environment(\.dynamicTypeSize) private var dynamicTypesize
    @State var viewState = ViewState.idle
    
    
    var body: some View {
        VStack {
            CloseButtonLayer(viewState: $viewState)
            Spacer()
            MeasurementLayer()
            Spacer()
            ConfirmMeasurementButton(viewState: $viewState)
        }
            .presentationDetents([dynamicDetente])
            .interactiveDismissDisabled(viewState != .idle)
    }
}


#Preview {
    struct MeasurementRecordedViewPreviewWrapper: View {
        @Environment(MeasurementManager.self) private var measurementManager
        @State private var viewState: ViewState = .idle
        
        
        var body: some View {
            @Bindable var measurementManager = measurementManager
            
            Button("Mock Measurement") {
                measurementManager.loadMockMeasurement()
            }
                .sheet(isPresented: $measurementManager.showSheet) {
                    MeasurementRecordedView()
                }
        }
    }
    
    return MeasurementRecordedViewPreviewWrapper()
        .previewWith(standard: ENGAGEHFStandard()) {
            MeasurementManager()
        }
}
