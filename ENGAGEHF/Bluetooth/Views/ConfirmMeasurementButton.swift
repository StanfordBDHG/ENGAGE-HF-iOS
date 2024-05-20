//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct DiscardButton: View {
    @Environment(\.dismiss) var dismiss
    @Binding var viewState: ViewState
    
    
    var body: some View {
        Button(
            action: {
                dismiss()
            },
            label: {
                Text("Discard")
                    .foregroundStyle(viewState == .idle ? Color.red : Color.gray)
            }
        )
            .disabled(viewState != .idle)
    }
}


struct ConfirmMeasurementButton: View {
    @Binding var viewState: ViewState
    
    
    var body: some View {
        VStack {
            AsyncButton(
               state: $viewState,
               action: {
                   try await MeasurementManager.manager.saveMeasurement()
               },
               label: {
                   Text("Save")
                       .frame(maxWidth: .infinity, maxHeight: 38)
                       .font(.title2)
                       .bold()
               }
           )
               .buttonStyle(.borderedProminent)
               .viewStateAlert(state: $viewState)
            
            DiscardButton(viewState: $viewState)
                .padding(.top, 10)
        }
            .padding()
    }
}

#Preview {
    @State var viewState = ViewState.idle
    return ConfirmMeasurementButton(viewState: $viewState)
}
