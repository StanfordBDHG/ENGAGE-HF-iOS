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
    let value: Double
    let idealHeight: CGFloat
    
    @ScaledMetric private var valueTextSize: CGFloat = 25.0
    @State private var viewState: ViewState = .idle
    
    
    private var startDate: String {
        interval.start.formatted(date: .abbreviated, time: .omitted)
    }
    
    private var endDate: String {
        interval.end.formatted(date: .abbreviated, time: .omitted)
    }
    
    
    var body: some View {
        VStack(alignment: .leading) {
            DisplayMeasurement(
                quantity: String(format: "%.1f", value),
                units: "%",
                type: "Avg Symptom Score",
                quantityTextSize: valueTextSize
            )
            Text(formatDateInterval(interval))
                .font(.headline)
                .foregroundStyle(.secondary)
        }
            .frame(idealHeight: idealHeight)
            .padding()
            .viewStateAlert(state: $viewState)
    }
    
    
    func formatDateInterval(_ dateInterval: DateInterval) -> String {
        let calendar = Calendar.current
        
        let startDate = dateInterval.start
        let endDate = dateInterval.end
        
        let sameDay = calendar.isDate(startDate, inSameDayAs: endDate)
        let sameMonth = calendar.isDate(startDate, equalTo: endDate, toGranularity: .month)
        let sameYear = calendar.isDate(startDate, equalTo: endDate, toGranularity: .year)
        
        let dateFormatter = DateFormatter()
        
        if sameDay {
            dateFormatter.dateFormat = "MMM d, yyyy"
            return dateFormatter.string(from: startDate)
        } else if sameMonth {
            dateFormatter.dateFormat = "MMM d"
            let startString = dateFormatter.string(from: startDate)
            
            dateFormatter.dateFormat = "d, yyyy"
            let endString = dateFormatter.string(from: endDate)
            
            return "\(startString) - \(endString)"
        } else if sameYear {
            dateFormatter.dateFormat = "MMM d"
            let startString = dateFormatter.string(from: startDate)
            
            dateFormatter.dateFormat = "MMM d, yyyy"
            let endString = dateFormatter.string(from: endDate)
            
            return "\(startString) - \(endString)"
        }
        
        dateFormatter.dateFormat = "MMM d, yyyy"
        
        let startString = dateFormatter.string(from: startDate)
        let endString = dateFormatter.string(from: endDate)
        
        return "\(startString) - \(endString)"
    }
}


#Preview {
    PointDetails(interval: DateInterval(start: .now, end: .now), value: 0.0, idealHeight: 60)
}
