//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import ExceptionCatcher
import Foundation
import SpeziHealthKit


/// Conformance to the Graphable protocol allows HKSamples to be displayed no matter what concrete subclass the instance is
extension HKSample: Graphable {
    /// Returns the date associated with the measurement
    /// For now, assumes each sample is associated with a single point in time, not a period
    public var date: Date { startDate }
    
    
    /// Returns the Double value corresponding to each quantity in the Sample in the given units, if compatable
    /// For now, only supports HKQuantitySamples and HKCorrelations
    public func getDoubleValues(for unitString: String) -> [Double] {
        let unit: HKUnit
        do {
            /// Make sure the unitString is well formed (HKUnit(from: String) throws an NSException which cannot be caught by the Swift do/catch block)
            /// Well formed strings can be found at:
            /// https://developer.apple.com/documentation/healthkit/hkunit/1615733-init
            unit = try ExceptionCatcher.catch {
                HKUnit(from: unitString)
            }
        } catch {
            return []
        }
        
        switch self {
        case let quantitySample as HKQuantitySample:
            let quantity = quantitySample.quantity
            
            guard quantity.is(compatibleWith: unit) else {
                return []
            }
            
            return [quantity.doubleValue(for: unit)]
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
            
            guard let systolicQuantity = systolic?.quantity,
                  let diastolicQuantity = diastolic?.quantity else {
                return []
            }
            
            guard systolicQuantity.is(compatibleWith: unit),
                  diastolicQuantity.is(compatibleWith: unit) else {
                return []
            }
            
            return [systolicQuantity.doubleValue(for: unit), diastolicQuantity.doubleValue(for: unit)]
        default:
            return []
        }
    }
}
