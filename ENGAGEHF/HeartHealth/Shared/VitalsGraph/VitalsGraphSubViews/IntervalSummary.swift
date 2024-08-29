//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct IntervalSummary: View {
    let quantity: String
    let interval: Range<Date>
    let unit: String
    let averaged: Bool
    let idealHeight: CGFloat
    let accessibilityLabel: String
    
    @ScaledMetric private var valueTextSize: CGFloat = 25.0
    
    
    private var displayInterval: String {
        interval.formatted(
            Date.IntervalFormatStyle()
                .day()
                .month(.abbreviated)
        )
    }
    
    
    var body: some View {
        VStack(alignment: .leading) {
            if averaged {
                Text("Average")
                    .font(.subheadline.bold())
                    .foregroundStyle(.secondary)
            } else {
                Spacer()
            }
            DisplayMeasurement(
                quantity: quantity,
                units: unit,
                type: accessibilityLabel,
                quantityTextSize: valueTextSize
            )
            Text(displayInterval)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
            .frame(idealHeight: idealHeight)
    }
}


#Preview {
    IntervalSummary(
        quantity: "60.0",
        interval: Date()..<Date(),
        unit: "%",
        averaged: true,
        idealHeight: 60,
        accessibilityLabel: "Symptom Score"
    )
}
