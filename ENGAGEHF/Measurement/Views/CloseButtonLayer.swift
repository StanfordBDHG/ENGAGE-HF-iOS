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
    
    
    var body: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Text(NSLocalizedString("Close", comment: "For closing sheets."))
                    .foregroundStyle(Color.accentColor)
            }
                .buttonStyle(PlainButtonStyle())
            
            Spacer()
        }
        .padding()
    }
    
    
    init() {}
}
