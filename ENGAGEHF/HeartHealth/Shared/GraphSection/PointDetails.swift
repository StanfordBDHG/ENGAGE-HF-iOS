//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct PointDetails: View {
    let interval: DateInterval
    let value: String
    let unit: String
    let idealHeight: CGFloat
    
    @ScaledMetric private var valueTextSize: CGFloat = 25.0
    @State private var viewState: ViewState = .idle
    
    
    private var displayInterval: String {
        let dateRange = interval.start ..< interval.end
        
        return dateRange.formatted(
            Date.IntervalFormatStyle()
                .day()
                .month(.abbreviated)
        )
    }
    
    
    var body: some View {
        VStack(alignment: .leading) {
            DisplayMeasurement(
                quantity: value,
                units: unit,
                type: "Avg Symptom Score",
                quantityTextSize: valueTextSize
            )
            Text(displayInterval)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
            .frame(idealHeight: idealHeight)
            .viewStateAlert(state: $viewState)
    }
}


#Preview {
    var startComponents = DateComponents()
    startComponents.year = 2024
    startComponents.month = 6
    startComponents.day = 23
    let startDate = Calendar.current.date(from: startComponents)!
    
    var endComponents = DateComponents()
    endComponents.year = 2024
    endComponents.month = 6
    endComponents.day = 27
    let endDate = Calendar.current.date(from: endComponents)!
    
    
    return PointDetails(
        interval: DateInterval(start: startDate, end: endDate),
        value: String(format: "%.1f", 67.2),
        unit: "%",
        idealHeight: 60
    )
}
