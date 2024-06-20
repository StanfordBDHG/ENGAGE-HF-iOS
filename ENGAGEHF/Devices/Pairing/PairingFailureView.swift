//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct PairingFailureView: View {
    private let error: any LocalizedError

    private var message: String {
        error.failureReason ?? error.errorDescription
        ?? String(localized: "Failed to pair accessory.")
    }

    @Environment(\.dismiss) private var dismiss


    var body: some View {
        PaneContent(title: Text("Pairing Failed"), subtitle: Text(message)) {
            Image(systemName: "exclamationmark.triangle.fill")
                .symbolRenderingMode(.hierarchical)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .accessibilityHidden(true)
                .frame(maxWidth: 250, maxHeight: 120)
                .foregroundStyle(.red)
        } action: {
            Button {
                dismiss()
            } label: {
                Text("OK")
                    .frame(maxWidth: .infinity, maxHeight: 35)
            }
                .buttonStyle(.borderedProminent)
                .padding([.leading, .trailing], 36)
        }
    }


    init(_ error: any LocalizedError) {
        self.error = error
    }
}


#if DEBUG
#Preview {
    SheetPreview {
        PairingFailureView(DevicePairingError.notInPairingMode)
    }
}
#endif
