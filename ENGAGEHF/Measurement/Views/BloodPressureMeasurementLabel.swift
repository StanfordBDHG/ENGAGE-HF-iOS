//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import SwiftUI


struct BloodPressureMeasurementLabel: View {
    private let bloodPressureSample: HKCorrelation
    private let heartRateSample: HKQuantitySample?

    @ScaledMetric private var measurementTextSize: CGFloat = 50

    private var bloodPressureQuantitySamples: [HKQuantitySample] {
        bloodPressureSample.objects
            .compactMap { sample in
                sample as? HKQuantitySample
            }
    }

    private var systolic: HKQuantitySample? {
        bloodPressureQuantitySamples
            .first(where: { $0.quantityType == HKQuantityType(.bloodPressureSystolic) })
    }

    private var diastolic: HKQuantitySample? {
        bloodPressureQuantitySamples
            .first(where: { $0.quantityType == HKQuantityType(.bloodPressureDiastolic) })
    }

    var body: some View {
        if let systolic,
           let diastolic {
            VStack(spacing: 5) {
                Text("\(Int(systolic.quantity.doubleValue(for: .millimeterOfMercury())))/\(Int(diastolic.quantity.doubleValue(for: .millimeterOfMercury()))) mmHg")
                    .font(.system(size: measurementTextSize, weight: .bold, design: .rounded))

                if let heartRateSample {
                    Text("\(Int(heartRateSample.quantity.doubleValue(for: .count().unitDivided(by: .minute())))) BPM")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
            }
        } else {
            Text("Invalid Sample")
                .italic()
        }
    }


    init(_ bloodPressureSample: HKCorrelation, heartRate heartRateSample: HKQuantitySample? = nil) {
        self.bloodPressureSample = bloodPressureSample
        self.heartRateSample = heartRateSample
    }
}


#if DEBUG
#Preview {
    BloodPressureMeasurementLabel(.mockBloodPressureSample, heartRate: .mockHeartRateSample)
}
#endif
