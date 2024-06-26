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
    private struct UnitsStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.title2)
                .foregroundStyle(Color.secondary)
        }
    }
    
    private struct MeasurementStyle: ViewModifier {
        @ScaledMetric private var measurementTextSize: CGFloat = 40
        
        func body(content: Content) -> some View {
            content
                .font(.system(size: measurementTextSize, weight: .semibold, design: .rounded))
        }
    }
    
    private struct DateStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.caption)
                .foregroundStyle(Color.secondary)
        }
    }
    
    private var displayDate: String? {
        date?.formatted(date: .numeric, time: .shortened)
    }
    
    
    let measurement: (type: String, value: String?)
    let units: String?
    let date: Date?
    
    private let cardHeight: CGFloat = 80
    
    
    var body: some View {
        StudyApplicationListCard {
            VStack(alignment: .center, spacing: 7) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    VitalsCardText(
                        quantityValue: measurement.value,
                        vitalType: measurement.type,
                        component: "Quantity",
                        style: MeasurementStyle()
                    )
                    VitalsCardText(
                        quantityValue: units,
                        vitalType: measurement.type,
                        component: "Unit",
                        style: UnitsStyle()
                    )
                }
                VitalsCardText(
                    quantityValue: displayDate,
                    vitalType: measurement.type,
                    component: "Date",
                    style: DateStyle()
                )
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
        measurement: (
            type: "Weight",
            value: "\(dummyWeight.quantity.doubleValue(for: .gramUnit(with: .kilo)))"
        ),
        units: "kg",
        date: dummyWeight.startDate
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
        measurement: (
            type: "Heart Rate",
            value: "\(dummyHR.quantity.doubleValue(for: .count().unitDivided(by: .minute())))"
        ),
        units: "BPM",
        date: dummyHR.startDate
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
        measurement: (
            type: "Blood Pressure",
            value: "\(Int(dummySystolic.quantity.doubleValue(for: .millimeterOfMercury())))/\(Int(dummyDiastolic.quantity.doubleValue(for: .millimeterOfMercury())))"
        ),
        units: "mmHg",
        date: dummyDiastolic.startDate
    )
}
