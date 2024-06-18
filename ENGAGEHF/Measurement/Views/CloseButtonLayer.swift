//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct CloseButtonLayer: View {
    @Environment(\.dismiss) private var dismiss
    @Binding private var viewState: ViewState
    
    
    var body: some View {
        HStack {
            Button(
                action: {
                    dismiss()
                },
                label: {
                    Text("Close", comment: "For closing sheets.")
                        .foregroundStyle(Color.accentColor)
                }
            )
                .buttonStyle(PlainButtonStyle())
                .disabled(viewState != .idle)
            
            Spacer()
        }
        .padding()
    }
    
    
    init(viewState: Binding<ViewState>) {
        self._viewState = viewState
    }
}

#Preview {
    CloseButtonLayer(viewState: .constant(.idle))
}
