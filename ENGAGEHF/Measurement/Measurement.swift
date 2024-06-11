//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import BluetoothServices


enum Measurement {
    case weight(WeightMeasurement, WeightScaleFeature)
    case bloodPressure(BloodPressureMeasurement, BloodPressureFeature)
}
