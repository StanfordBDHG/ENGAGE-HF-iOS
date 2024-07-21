//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct DisplayMeasurement: View {
    let quantity: String
    let units: String
    let type: String
    @ScaledMetric var quantityTextSize: CGFloat
    
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(quantity)
                .font(.system(size: quantityTextSize, weight: .semibold, design: .rounded))
                .accessibilityLabel("\(type) Quantity: \(quantity)")
            Text(units)
                .font(.title3)
                .foregroundStyle(Color.secondary)
                .accessibilityLabel("\(type) Unit: \(units)")
        }
    }
}


#Preview {
    DisplayMeasurement(quantity: "90.0", units: "lb", type: "Weight", quantityTextSize: 40.0)
}
