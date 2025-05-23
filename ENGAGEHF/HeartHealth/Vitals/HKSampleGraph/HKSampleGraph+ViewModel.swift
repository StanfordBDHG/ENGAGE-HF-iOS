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
        private(set) var displayUnit: String?
        private(set) var formatter: ([(String, Double)]) -> String = { _ in "No Data" }
        private(set) var targetValue: SeriesTarget?
        
        
        func processTargetValue(_ target: HKSample?) {
            guard let target else {
                self.targetValue = nil
                return
            }
            
            guard let (hkUnits, _) = getUnits(data: [target]) else {
                self.targetValue = nil
                return
            }
            
            switch target {
            case let quantitySample as HKQuantitySample:
                switch quantitySample.quantityType.identifier {
                case HKQuantityTypeIdentifier.bodyMass.rawValue:
                    self.targetValue = SeriesTarget(
                        value: quantitySample.quantity.doubleValue(for: hkUnits),
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
            guard !data.isEmpty else {
                self.seriesData = [:]
                self.displayUnit = nil
                return
            }
            
            
            guard let (hkUnits, unitString) = getUnits(data: data) else {
                return
            }
            
            let allData: [VitalMeasurement] = data.flatMap { measurement in
                switch measurement {
                case let quantitySample as HKQuantitySample:
                    return [
                        VitalMeasurement(
                            date: quantitySample.startDate,
                            value: quantitySample.quantity.doubleValue(for: hkUnits),
                            type: KnownVitalsSeries(matching: quantitySample.quantityType.identifier)?.rawValue ?? "-"
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
        
        private func getUnits(data: [HKSample]) -> (HKUnit, String)? {
            guard let sample = data.first else {
                return nil
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
                return nil
            }
            
            return identifiedUnits
        }
        
        private func getUnitsFor(identifier: String) -> (HKUnit, String)? {
            guard let series = KnownVitalsSeries(matching: identifier) else {
                return nil
            }
            
            switch series {
            case .heartRate:
                self.formatter = {
                    guard let matchingData = $0.first(where: { $0.0 == series.rawValue })?.1 else {
                        return String(localized: "No Data", comment: "No data available")
                    }
                    return "\(Int(matchingData))"
                }
                return (HKUnit.count().unitDivided(by: .minute()), String(localized: "BPM", comment: "Beats per minute"))
            case .bodyWeight:
                self.formatter = {
                    guard let matchingData = $0.first(where: { $0.0 == series.rawValue })?.1 else {
                        return String(localized: "No Data", comment: "No data available")
                    }
                    return String(format: "%.1f", matchingData)
                }
                return Locale.current.measurementSystem == .us ? (HKUnit.pound(), "lb") : (HKUnit.gramUnit(with: .kilo), "kg")
            case .bloodPressureSystolic, .bloodPressureDiastolic:
                self.formatter = {
                    let systolic = $0.first(where: { $0.0 == KnownVitalsSeries.bloodPressureSystolic.rawValue })?.1
                    let diastolic = $0.first(where: { $0.0 == KnownVitalsSeries.bloodPressureDiastolic.rawValue })?.1
                    
                    var systolicString = String(localized: "No Data", comment: "No data available")
                    if let systolic {
                        systolicString = "\(Int(systolic))"
                    }
                    var diastolicString = String(localized: "No Data", comment: "No data available")
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
