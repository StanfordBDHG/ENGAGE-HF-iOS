//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import HealthKit


enum ProcessedMeasurement {
    case weight(HKQuantitySample)
    case bloodPressure(HKCorrelation, heartRate: HKQuantitySample? = nil)
}


extension ProcessedMeasurement: Identifiable {
    var id: ObjectIdentifier {
        switch self {
        case let .weight(sample):
            sample.id
        case let .bloodPressure(sample, _):
            sample.id
        }
    }
}
