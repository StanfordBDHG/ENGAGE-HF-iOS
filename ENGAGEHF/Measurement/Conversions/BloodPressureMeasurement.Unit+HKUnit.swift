//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//


import BluetoothServices
import HealthKit


extension BloodPressureMeasurement.Unit {
    var hkUnit: HKUnit {
        switch self {
        case .mmHg:
            return .millimeterOfMercury()
        case .kPa:
            return .pascalUnit(with: .kilo)
        }
    }
}
