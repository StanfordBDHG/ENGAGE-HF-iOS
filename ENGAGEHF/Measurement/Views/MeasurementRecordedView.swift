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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State var viewState = ViewState.idle
    

    private var dynamicDetents: PresentationDetent {
        switch dynamicTypeSize {
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


    var body: some View {
        VStack {
            CloseButtonLayer(viewState: $viewState)
            Spacer()
            MeasurementLayer()
            Spacer()
            ConfirmMeasurementButton(viewState: $viewState)
        }
            .presentationDetents([dynamicDetents])
            .interactiveDismissDisabled(viewState != .idle)
    }
}


#if DEBUG
#Preview {
    let measurementManager = MeasurementManager()
    measurementManager.loadMockMeasurement()

    return Text(verbatim: "")
        .sheet(isPresented: .constant(true)) {
            MeasurementRecordedView()
        }
        .previewWith(standard: ENGAGEHFStandard()) {
            measurementManager
        }
}

#Preview {
    let measurementManager = MeasurementManager()
    measurementManager.loadMockBloodPressureMeasurement()

    return Text(verbatim: "")
        .sheet(isPresented: .constant(true)) {
            MeasurementRecordedView()
        }
        .previewWith(standard: ENGAGEHFStandard()) {
            measurementManager
        }
}
#endif
