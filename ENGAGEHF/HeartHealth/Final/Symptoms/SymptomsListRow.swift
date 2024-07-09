//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct SymptomsListRow: View {
    var displayQuantity: String
    var displayUnit: String
    var displayDate: String
    var type: String
    
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            DisplayMeasurement(
                quantity: displayQuantity,
                units: displayUnit,
                type: type,
                quantityTextSize: 25.0
            )
            Spacer()
            Text(displayDate)
                .font(.title2)
                .foregroundStyle(Color.secondary)
                .accessibilityLabel("\(type) Date: \(displayDate)")
        }
    }
}


#Preview {
    SymptomsListRow(
        displayQuantity: "90.0",
        displayUnit: "lbs",
        displayDate: "6/23/2024",
        type: "Symptom Overall"
    )
}
