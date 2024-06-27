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


struct HKSampleGraph: View {
    var data: [HKSample]
    
    
//    // The lower range to display on the Y-Axis in the chart
//    private var minValue: Int {
//        let minQuantity = data.min {
//            $0.quantity.doubleValue(for: units) < $1.quantity.doubleValue(for: units)
//        }
//        
//        if let minDouble = minQuantity?.quantity.doubleValue(for: units) {
//            return Int(floor(minDouble)) - 1
//        }
//        
//        return 0
//    }
//    
//    // The upper range to display on the Y-Axis in the chart
//    private var maxValue: Int {
//        let maxQuantity = data.max {
//            $0.quantity.doubleValue(for: units) < $1.quantity.doubleValue(for: units)
//        }
//        
//        if let maxDouble = maxQuantity?.quantity.doubleValue(for: units) {
//            return Int(ceil(maxDouble)) + 1
//        }
//        return 0
//    }
    
    
    var body: some View {
//        Chart(data) { sample in
//            LineMark(
//                x: .value("Date", sample.startDate, unit: dateResolution),
//                y: .value(units.unitString, sample.quantity.doubleValue(for: units))
//            )
//        }
//        .chartYScale(domain: [minValue, maxValue])
        Text("Graph")
    }
}


#Preview("Weight") {
    struct HKSampleGraphPreviewWrapper<T>: View {
        @Environment(VitalsManager.self) private var vitalsManager
        var storage: ReferenceWritableKeyPath<VitalsManager, [T]>
        
        
        var body: some View {
            HKSampleGraph(
                data: vitalsManager[keyPath: storage] as? [HKSample] ?? []
            )
        }
    }
    
    return HKSampleGraphPreviewWrapper(storage: \.weightHistory)
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}
