//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct EmptyMedicationsView: View {
    var body: some View {
        Text("No medication recommendations currently available.")
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}


#Preview {
    EmptyMedicationsView()
}
