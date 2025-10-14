//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI


struct AccountButton: View {
    static let shouldDisplay = !FeatureFlags.disableFirebase || ProcessInfo.processInfo.isPreviewSimulator

    @Binding private var isPresented: Bool


    var body: some View {
        Button(action: {
            isPresented = true
        }) {
            Image(systemName: "person.crop.circle")
        }
            .accessibilityLabel("ACCOUNT_TITLE")
    }


    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
}


#if DEBUG
#Preview(traits: .sizeThatFitsLayout) {
    AccountButton(isPresented: .constant(false))
}
#endif
