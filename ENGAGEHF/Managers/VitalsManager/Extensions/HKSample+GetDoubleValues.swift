//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit


extension HKSample {
    /// Returns the Double value corresponding to each quantity in the Sample in the given units, if compatable
    /// For now, only supports HKQuantitySamples and HKCorrelations
    func getDoubleValues(for unit: HKUnit) -> [String: Double] {
        switch self {
        case let quantitySample as HKQuantitySample:
            let quantity = quantitySample.quantity
            
            guard quantity.is(compatibleWith: unit) else {
                return [:]
            }
            
            return [quantitySample.quantityType.identifier: quantity.doubleValue(for: unit)]
        case let correlation as HKCorrelation:
            /// For now, assume the HKCorrelation is a Blood Pressure measurement
            let quantitySamples = correlation.objects.compactMap { $0 as? HKQuantitySample }
            
            var systolic: HKQuantitySample? {
                quantitySamples
                    .first(where: { $0.quantityType == HKQuantityType(.bloodPressureSystolic) })
            }
            var diastolic: HKQuantitySample? {
                quantitySamples
                    .first(where: { $0.quantityType == HKQuantityType(.bloodPressureDiastolic) })
            }
            
            guard let systolic, let diastolic else {
                return [:]
            }
            
            guard systolic.quantity.is(compatibleWith: unit),
                  diastolic.quantity.is(compatibleWith: unit) else {
                return [:]
            }
            
            return [
                systolic.quantityType.identifier: systolic.quantity.doubleValue(for: unit),
                diastolic.quantityType.identifier: diastolic.quantity.doubleValue(for: unit)
            ]
        default:
            return [:]
        }
    }
}
