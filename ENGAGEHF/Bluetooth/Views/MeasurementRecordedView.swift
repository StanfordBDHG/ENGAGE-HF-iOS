//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct MeasurementHeader: View {
    @Environment(\.dismiss) var dismiss
    @Binding var viewState: ViewState
    
    
    var body: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Text("DISMISS_BUTTON")
                    .foregroundStyle(Color.accentColor)
            }
                .buttonStyle(PlainButtonStyle())
                .disabled(viewState != .idle)
                .accessibilityLabel("Dismiss")
            
            Spacer()
            
            Text("Measurement Recorded")
                .font(.title2)
            
            Spacer()
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

#Preview {
    MeasurementRecordedView(viewState: .constant(.idle))
}
