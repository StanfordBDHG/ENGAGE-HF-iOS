//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import SwiftUI


struct VitalsCard: View {
    let type: String
    let units: String
    let measurement: (value: String, date: String)?
    
    var measurementTextSize: CGFloat = 40
    private let cardHeight: CGFloat = 80
    
    
    var body: some View {
        StudyApplicationListCard {
            VStack(alignment: .center, spacing: 7) {
                if let measurement {
                    DisplayMeasurement(
                        quantity: measurement.value,
                        units: units,
                        type: type,
                        quantityTextSize: measurementTextSize
                    )
                    Text(measurement.date)
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                        .accessibilityLabel("\(type) Date: \(measurement.date)")
                } else {
                    Text("No recent \(type.lowercased()) measurement available")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .accessibilityLabel("No vitals")
                }
            }
                .frame(maxWidth: .infinity, idealHeight: cardHeight, maxHeight: .infinity)
        }
    }
}


#Preview("Weight") {
    let dummyWeight = HKQuantitySample(
        type: HKQuantityType(.bodyMass),
        quantity: HKQuantity(unit: .gramUnit(with: .kilo), doubleValue: Double(70)),
        start: .now,
        end: .now
    )
    
    return VitalsCard(
        type: "Weight",
        units: "kg",
        measurement: (
            value: "\(dummyWeight.quantity.doubleValue(for: .gramUnit(with: .kilo)))",
            date: dummyWeight.startDate.formatted(date: .numeric, time: .shortened)
        )
    )
}

#Preview("Heart Rate") {
    let dummyHR = HKQuantitySample(
        type: HKQuantityType(.heartRate),
        quantity: HKQuantity(unit: .count().unitDivided(by: .minute()), doubleValue: Double(60)),
        start: .now,
        end: .now
    )
    
    return VitalsCard(
        type: "Heart Rate",
        units: "BPM",
        measurement: (
            value: "\(Int(dummyHR.quantity.doubleValue(for: .count().unitDivided(by: .minute()))))",
            date: dummyHR.startDate.formatted(date: .numeric, time: .shortened)
        )
    )
}

#Preview("Blood Pressure") {
    let diastolic = HKQuantity(unit: .millimeterOfMercury(), doubleValue: Double(120))
    let systolic = HKQuantity(unit: .millimeterOfMercury(), doubleValue: Double(70))
    
    let dummyDiastolic = HKQuantitySample(
        type: HKQuantityType(.bloodPressureDiastolic),
        quantity: diastolic,
        start: .now,
        end: .now
    )
    let dummySystolic = HKQuantitySample(
        type: HKQuantityType(.bloodPressureSystolic),
        quantity: systolic,
        start: .now,
        end: .now
    )
    
    return VitalsCard(
        type: "Blood Pressure",
        units: "mmHg",
        measurement: (
            value: "\(Int(dummySystolic.quantity.doubleValue(for: .millimeterOfMercury())))/\(Int(dummyDiastolic.quantity.doubleValue(for: .millimeterOfMercury())))",
            date: dummyDiastolic.startDate.formatted(date: .numeric, time: .shortened)
        )
    )
}

#Preview("None") {
    VitalsCard(type: "Weight", units: "lb", measurement: nil)
}
