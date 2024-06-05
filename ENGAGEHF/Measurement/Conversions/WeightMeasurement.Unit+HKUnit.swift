//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import BluetoothServices
import HealthKit


extension WeightMeasurement.Unit {
    var massUnit: HKUnit {
        switch self {
        case .si:
            return .gramUnit(with: .kilo)
        case .imperial:
            return .pound()
        }
    }
}
