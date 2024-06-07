//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import BluetoothServices
import HealthKit


extension WeightMeasurement {
    func quantitySample(source device: HKDevice?, resolution: WeightScaleFeature.WeightResolution?) -> HKQuantitySample {
        let quantityType = HKQuantityType(.bodyMass)

        let value = weight(of: resolution ?? .unspecified)

        let quantity = HKQuantity(unit: unit.massUnit, doubleValue: value)
        let date = timeStamp?.date ?? .now

        return HKQuantitySample(
            type: quantityType,
            quantity: quantity,
            start: date,
            end: date,
            device: device,
            metadata: nil
        )
    }
}

#if DEBUG || TEST
extension HKQuantitySample {
    static var mockWeighSample: HKQuantitySample {
        let measurement = WeightMeasurement(weight: 8400, unit: .si)

        return measurement.quantitySample(source: nil, resolution: .resolution5g)
    }
}
#endif
