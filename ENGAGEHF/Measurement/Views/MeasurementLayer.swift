//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import SwiftUI


struct MeasurementLayer: View {
    private let measurement: ProcessedMeasurement

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(spacing: 15) {
            switch measurement {
            case let .weight(sample):
                WeightMeasurementLabel(sample)
            case let .bloodPressure(bloodPressure, heartRate):
                BloodPressureMeasurementLabel(bloodPressure, heartRate: heartRate)
            }
            
            if dynamicTypeSize < .accessibility4 {
                Text("Measurement Recorded")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
            .multilineTextAlignment(.center)
    }


    init(measurement: ProcessedMeasurement) {
        self.measurement = measurement
    }
}


#if DEBUG
#Preview {
    MeasurementLayer(measurement: .weight(.mockWeighSample))
}

#Preview {
    MeasurementLayer(measurement: .bloodPressure(.mockBloodPressureSample, heartRate: .mockHeartRateSample))
}
#endif
