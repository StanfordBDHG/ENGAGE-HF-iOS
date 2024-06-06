//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import SwiftUI


struct WeightMeasurementLabel: View {
    private let sample: HKQuantitySample

    @ScaledMetric private var measurementTextSize: CGFloat = 60

    var body: some View {
        Text(sample.quantity.description)
            .font(.system(size: measurementTextSize, weight: .bold, design: .rounded))
    }


    init(_ sample: HKQuantitySample) {
        self.sample = sample
    }
}


#if DEBUG
#Preview {
    WeightMeasurementLabel(.mockWeighSample)
}
#endif
