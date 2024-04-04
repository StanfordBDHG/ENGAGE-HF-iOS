//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct Greeting: View {
    var body: some View {
        HStack(alignment: .top) {
            Text("Hello, world!")
                .font(.title.bold())
                .accessibilityLabel(Text("DASHBOARD_GREETING"))
            Spacer()
            Text(.now, style: .date)
                .font(.title3)
                .foregroundStyle(.secondary)
                .accessibilityLabel(Text("DASHBOARD_DATE"))
        }
        .padding()
    }
}

#Preview {
    Greeting()
}
