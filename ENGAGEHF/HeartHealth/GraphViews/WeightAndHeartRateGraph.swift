//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Charts
import HealthKit
import SwiftUI


struct WeightAndHeartRateGraph: View {
    var data: [HKQuantitySample]
    var units: HKUnit
    @Binding var dateResolution: Calendar.Component
    
    
    // The lower range to display on the Y-Axis in the chart
    private var minValue: Int {
        let minQuantity = data.min {
            $0.quantity.doubleValue(for: units) < $1.quantity.doubleValue(for: units)
        }
        
        if let minDouble = minQuantity?.quantity.doubleValue(for: units) {
            return Int(floor(minDouble)) - 1
        }
        
        return 0
    }
    
    // The upper range to display on the Y-Axis in the chart
    private var maxValue: Int {
        let maxQuantity = data.max {
            $0.quantity.doubleValue(for: units) < $1.quantity.doubleValue(for: units)
        }
        
        if let maxDouble = maxQuantity?.quantity.doubleValue(for: units) {
            return Int(ceil(maxDouble)) + 1
        }
        return 0
    }
    
    
    var body: some View {
        Chart(data) { sample in
            LineMark(
                x: .value("Date", sample.startDate, unit: dateResolution),
                y: .value(units.unitString, sample.quantity.doubleValue(for: units))
            )
        }
        .chartYScale(domain: [minValue, maxValue])
    }
}


#Preview {
    struct WeightAndHeartRateGraphPreviewWrapper: View {
        @Environment(VitalsManager.self) private var vitalsManager
        
        
        var body: some View {
            WeightAndHeartRateGraph(
                data: vitalsManager.weightHistory,
                units: .pound(),
                dateResolution: .constant(.day)
            )
        }
    }
    
    return WeightAndHeartRateGraphPreviewWrapper()
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}
