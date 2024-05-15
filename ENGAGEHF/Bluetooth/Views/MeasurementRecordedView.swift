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


struct MeasurementHeader: View {
    @Environment(\.dismiss) var dismiss
    @Binding var viewState: ViewState
    
    
    var body: some View {
        ZStack {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Text("DISMISS_BUTTON")
                        .foregroundStyle(Color.accentColor)
                }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 10)
                    .disabled(viewState != .idle)
                    .accessibilityLabel("Dismiss")
                
                Spacer()
            }
            
            HStack {
                Spacer()
                
                Text("Measurement Recorded")
                    .font(.title2)
                
                Spacer()
            }
        }
            .padding()
    }
}


struct MeasurementLayer: View {
    private var measurement = MeasurementManager.manager.newMeasurement
    private var textSize: CGFloat = 60
    
    
    var body: some View {
        Text(measurement?.quantity.description ?? "???")
            .font(.system(size: textSize, weight: .bold, design: .rounded))
    }
}


struct DiscardButton: View {
    @Environment(\.dismiss) var dismiss
    
    
    var body: some View {
        Button(action: {
            dismiss()
        }) {
            Text("DISCARD")
                .foregroundStyle(Color.red)
        }
    }
}


struct ConfirmMeasurementButton: View {
    @Binding var viewState: ViewState
    
    
    var body: some View {
        VStack {
            AsyncButton(state: $viewState, action: {
                try await MeasurementManager.manager.saveMeasurement()
            }) {
                Text("Save")
                    .frame(maxWidth: .infinity, maxHeight: 48)
                    .foregroundStyle(.white)
                    .background(.accent)
                    .cornerRadius(8)
            }
                .viewStateAlert(state: $viewState)
            
            DiscardButton()
                .disabled(viewState != .idle)
        }
    }
}


struct MeasurementRecordedView: View {
    @Binding var viewState: ViewState
    
    var body: some View {
        VStack {
            MeasurementHeader(viewState: $viewState)
            
            Spacer()
            
            MeasurementLayer()
            
            Spacer()
            
            ConfirmMeasurementButton(viewState: $viewState)
                .padding()
            
            Spacer()
        }
    }
}


private struct MeasurementRecordedViewPreviewWrapper: View {
    @Environment(MeasurementManager.self) private var measurementManager
    @State private var viewState: ViewState = .idle
    
    
    var body: some View {
        @Bindable var measurementManager = measurementManager
        
        Button("Mock Measurement") {
            loadMockMeasurement()
        }
            .sheet(isPresented: $measurementManager.showSheet) {
                MeasurementRecordedView(viewState: $viewState)
            }
    }
    
    
    private func loadMockMeasurement() {
        measurementManager.deviceName = "Mock Device"
        
        let deviceInformation = DeviceInformationService()
        deviceInformation.$manufacturerName.inject("Mock")
        deviceInformation.$modelNumber.inject("42")
        deviceInformation.$hardwareRevision.inject("42")
        deviceInformation.$firmwareRevision.inject("42")
        deviceInformation.$softwareRevision.inject("42")
        measurementManager.deviceInformation = deviceInformation
        
        measurementManager.weightScaleParams = WeightScaleFeature(
            timeStampEnabled: true,
            supportMultipleUsers: true,
            supportBMI: true,
            weightResolution: .gradeSix,
            heightResolution: .gradeThree
        )
        
        measurementManager.loadMeasurement(
            WeightMeasurement(
                units: .metric,
                timeStampPresent: true,
                userIDPresent: true,
                heightBMIPresent: true,
                weight: 8400,
                timeStamp: DateTime(hours: 0, minutes: 0, seconds: 0),
                bmi: 20,
                height: 180,
                userID: 42
            )
        )
    }
}


#Preview {
    MeasurementRecordedViewPreviewWrapper()
        .previewWith(standard: ENGAGEHFStandard()) {
            MeasurementManager()
        }
}
