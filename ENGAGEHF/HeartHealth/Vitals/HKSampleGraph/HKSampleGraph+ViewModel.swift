//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit
import SpeziViews


extension HKSampleGraph {
    @Observable
    class ViewModel {
        var viewState: ViewState = .idle
        
        private(set) var seriesData: SeriesDictionary = [:]
        private(set) var displayUnit = ""
        private(set) var formatter: ([(String, Double)]) -> String = { _ in "---" }
        private(set) var targetValue: SeriesTarget?
        
        
        func processTargetValue(_ target: HKSample?) {
            guard let target else {
                self.targetValue = nil
                return
            }
            
            let (hkUnits, unitString) = getUnits(data: [target])
            
            switch target {
            case let quantitySample as HKQuantitySample:
                switch quantitySample.quantityType.identifier {
                case HKQuantityTypeIdentifier.bodyMass.rawValue:
                    self.targetValue = SeriesTarget(
                        value: quantitySample.quantity.doubleValue(for: hkUnits),
                        unit: unitString,
                        date: quantitySample.startDate,
                        label: "Dry Weight"
                    )
                default:
                    self.targetValue = nil
                }
            default:
                self.targetValue = nil
            }
        }
        
        
        func processData(data: [HKSample]) {
            let (hkUnits, unitString) = getUnits(data: data)
            
            let allData: [VitalMeasurement] = data.flatMap { measurement in
                switch measurement {
                case let quantitySample as HKQuantitySample:
                    return [
                        VitalMeasurement(
                            date: quantitySample.startDate,
                            value: quantitySample.quantity.doubleValue(for: hkUnits),
                            type: KnownVitalsSeries(matching: quantitySample.quantityType.identifier)?.rawValue ?? "Unknown"
                        )
                    ]
                case let correlation as HKCorrelation:
                    // For now, just handling the case where the correlation is blood pressure
                    let doubleValues = correlation.getDoubleValues(for: hkUnits)
                    
                    let systolicIdentifier = HKQuantityTypeIdentifier.bloodPressureSystolic
                    let diastolicIdentifier = HKQuantityTypeIdentifier.bloodPressureDiastolic
                    
                    let systolic = doubleValues[systolicIdentifier.rawValue] ?? 0
                    let diastolic = doubleValues[diastolicIdentifier.rawValue] ?? 0
                    
                    return [
                        VitalMeasurement(
                            date: correlation.startDate,
                            value: systolic,
                            type: KnownVitalsSeries.bloodPressureSystolic.rawValue
                        ),
                        VitalMeasurement(
                            date: correlation.startDate,
                            value: diastolic,
                            type: KnownVitalsSeries.bloodPressureDiastolic.rawValue
                        )
                    ]
                default:
                    viewState = .error(HKSampleGraphError.unknownHKSample)
                    return []
                }
            }
            
            self.seriesData = Dictionary(grouping: allData) { $0.type }
            self.displayUnit = unitString
        }
        
        private func getUnits(data: [HKSample]) -> (HKUnit, String) {
            guard let sample = data.first else {
                viewState = .error(HKSampleGraphError.failedToFetchUnits)
                return (HKUnit.pound(), "lb")   // Dummy value
            }
            
            // For now, only allow for HKQuantitySample and HKCorrelation
            let identifiedUnits: (hkUnit: HKUnit, display: String)?
            switch sample {
            case let quantitySample as HKQuantitySample:
                identifiedUnits = getUnitsFor(identifier: quantitySample.quantityType.identifier)
            case let correlation as HKCorrelation:
                identifiedUnits = getUnitsFor(identifier: correlation.correlationType.identifier)
            default:
                identifiedUnits = nil
            }
            
            guard let identifiedUnits else {
                viewState = .error(HKSampleGraphError.failedToFetchUnits)
                return (HKUnit.pound(), "lb")   // Dummy value
            }
            
            return identifiedUnits
        }
        
        private func getUnitsFor(identifier: String) -> (HKUnit, String)? {
            guard let series = KnownVitalsSeries(matching: identifier) else {
                return nil
            }
            
            switch series {
            case .heartRate:
                self.formatter = { "\(Int($0.first(where: { $0.0 == series.rawValue })?.1 ?? 0))" }
                return (HKUnit.count().unitDivided(by: .minute()), "BPM")
            case .bodyWeight:
                self.formatter = { String(format: "%.1f", $0.first(where: { $0.0 == series.rawValue })?.1 ?? 0) }
                return Locale.current.measurementSystem == .us ? (HKUnit.pound(), "lb") : (HKUnit.gramUnit(with: .kilo), "kg")
            case .bloodPressureSystolic, .bloodPressureDiastolic:
                self.formatter = {
                    let systolic = $0.first(where: { $0.0 == KnownVitalsSeries.bloodPressureSystolic.rawValue })?.1
                    let diastolic = $0.first(where: { $0.0 == KnownVitalsSeries.bloodPressureDiastolic.rawValue })?.1
                    
                    var systolicString = "---"
                    if let systolic {
                        systolicString = "\(Int(systolic))"
                    }
                    var diastolicString = "---"
                    if let diastolic {
                        diastolicString = "\(Int(diastolic))"
                    }
                    
                    return "\(systolicString)/\(diastolicString)"
                }
                return (HKUnit.millimeterOfMercury(), "mmHg")
            default:
                return nil
            }
        }
    }
}
