//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct MeasurementListRow: View {
    let displayQuantity: String?
    let displayUnit: String?
    let displayDate: String
    let type: String
    
    
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
                .font(.title3)
                .foregroundStyle(Color.secondary)
                .accessibilityLabel("\(type) Date: \(displayDate)")
                .accessibilityIdentifier("Measurement Row")
        }
    }
}


#Preview {
     MeasurementListRow(
        displayQuantity: "90.0",
        displayUnit: "lbs",
        displayDate: "6/23/2024",
        type: "Symptom Overall"
    )
}
