//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI
import HealthKit // TODO: remove?


struct MeasurementLayer: View {
    @Environment(MeasurementManager.self) private var measurementManager
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @ScaledMetric private var measurementTextSize: CGFloat = 50 // TODO: was 60

    var body: some View {
        VStack(spacing: 15) {
            switch measurementManager.newMeasurement {
            case let .weight(sample):
                Text(sample.quantity.description)
                    .font(.system(size: measurementTextSize, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
            case let .bloodPressure(bloodPressure, heartRate):
                let systolic = bloodPressure.objects
                    .compactMap { sample in
                        sample as? HKQuantitySample
                    }
                    .first(where: { $0.quantityType == HKQuantityType(.bloodPressureSystolic) })!
                let diastolic = bloodPressure.objects
                    .compactMap { sample in
                        sample as? HKQuantitySample
                    }
                    .first(where: { $0.quantityType == HKQuantityType(.bloodPressureDiastolic) })!

                // TODO: units!
                VStack(spacing: 8) {
                    Text("\(Int(systolic.quantity.doubleValue(for: .millimeterOfMercury())))/\(Int(diastolic.quantity.doubleValue(for: .millimeterOfMercury()))) mmHg")
                        .font(.system(size: measurementTextSize, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                    if let heartRate {
                        Text("\(Int(heartRate.quantity.doubleValue(for: .count().unitDivided(by: .minute())))) BPM")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
            default:
                EmptyView() // TODO: support other!
            }
            if dynamicTypeSize < .accessibility4 {
                Text("Measurement Recorded")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}


#if DEBUG
#Preview {
    struct PreviewWrapperMeasurementLayer: View {
        @Environment(MeasurementManager.self) private var measurementManager
        
        
        var body: some View {
            MeasurementLayer()
                .onAppear {
                    measurementManager.loadMockMeasurement()
                }
        }
    }
    
    return PreviewWrapperMeasurementLayer()
        .previewWith(standard: ENGAGEHFStandard()) {
            MeasurementManager()
        }
}

#Preview {
    struct PreviewWrapperMeasurementLayer: View {
        @Environment(MeasurementManager.self) private var measurementManager


        var body: some View {
            MeasurementLayer()
                .onAppear {
                    measurementManager.loadMockBloodPressureMeasurement()
                }
        }
    }

    return PreviewWrapperMeasurementLayer()
        .previewWith(standard: ENGAGEHFStandard()) {
            MeasurementManager()
        }
}
#endif
