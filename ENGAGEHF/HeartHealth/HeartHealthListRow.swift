//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct HeartHealthListRow: View {
    var quantity: String
    var units: String
    var date: String
    var type: String
    
    
    var body: some View {
        HStack {
            Text(date)
                .font(.title2)
            Spacer()
            DisplayMeasurement(
                quantity: quantity,
                units: units,
                type: type,
                quantityTextSize: 25.0
            )
        }
    }
}


#Preview {
    HeartHealthListRow(
        quantity: "90.0",
        units: "%",
        date: "6/23/2024",
        type: "Overall"
    )
}
