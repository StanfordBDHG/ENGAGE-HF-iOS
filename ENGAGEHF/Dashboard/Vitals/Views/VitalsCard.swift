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
    @Environment(\.colorScheme) private var colorScheme
    @ScaledMetric private var quantityTextSize: CGFloat = 20
    
    let quantity: String?
    let units: String?
    let type: String?
    let date: Date?
    
    
    var body: some View {
        StudyApplicationListCard {
            VStack(alignment: .center, spacing: 10) {
                Text(type ?? "Unknown")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                HStack {
                    Text(quantity ?? "???")
                        .font(.system(size: quantityTextSize, weight: .semibold, design: .rounded))
                        .multilineTextAlignment(.center)
                    Text(units ?? "???")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondary)
                        .multilineTextAlignment(.center)
                }
                Text(date?.formatted(date: .numeric, time: .omitted) ?? "???")
                    .multilineTextAlignment(.center)
            }
                .frame(maxWidth: .infinity, idealHeight: 100.0)
        }
//            .padding()
//            .frame(maxWidth: .infinity, idealHeight: 100.0)
//            .background {
//                Color(uiColor: colorScheme == .light ? .systemBackground : .secondarySystemBackground)
//                    .ignoresSafeArea()
//            }
//            .clipShape(RoundedRectangle(cornerRadius: 10.0))
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
        quantity: "\(dummyWeight.quantity.doubleValue(for: .pound()))",
        units: "lb",
        type: "Weight",
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
        quantity: "\(dummyHR.quantity.doubleValue(for: .count().unitDivided(by: .minute())))",
        units: "BPM",
        type: "Heart Rate",
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
        quantity: "\(dummySystolic.quantity.doubleValue(for: .millimeterOfMercury()))/\(dummyDiastolic.quantity.doubleValue(for: .millimeterOfMercury()))",
        units: "mmHg",
        type: "Blood Pressure",
        date: dummyDiastolic.startDate
    )
}
