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
        Button {
            dismiss()
        } label: {
            Text("Discard")
                .foregroundStyle(viewState == .idle ? Color.red : Color.gray)
        }
            .disabled(viewState != .idle)
    }
}


struct ConfirmMeasurementButton: View {
    private let confirm: () async throws -> Void

    @ScaledMetric private var buttonHeight: CGFloat = 38
    @Binding var viewState: ViewState
    
    @Environment(MeasurementManager.self) private var measurementManager

    var body: some View {
        VStack {
            AsyncButton(state: $viewState, action: confirm) {
                Text("Save")
                    .frame(maxWidth: .infinity, maxHeight: buttonHeight)
                    .font(.title2)
                    .bold()
            }
               .buttonStyle(.borderedProminent)
            
            DiscardButton(viewState: $viewState)
                .padding(.top, 10)
        }
            .padding()
    }

    init(viewState: Binding<ViewState>, confirm: @escaping () async throws -> Void) {
        self._viewState = viewState
        self.confirm = confirm
    }
}


#if DEBUG
#Preview {
    ConfirmMeasurementButton(viewState: .constant(.idle)) {
        print("Save")
    }
}
#endif
