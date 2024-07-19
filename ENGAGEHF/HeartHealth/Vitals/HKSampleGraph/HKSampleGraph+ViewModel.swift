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
        
        
        func processData(data: [HKSample]) {
            let (hkUnits, unitString) = getUnits(data: data)
            
            let allData: [VitalMeasurement] = data.flatMap { measurement in
                switch measurement {
                case let quantitySample as HKQuantitySample:
                    return [
                        VitalMeasurement(
                            date: quantitySample.startDate,
                            value: quantitySample.quantity.doubleValue(for: hkUnits),
                            type: quantitySample.quantityType.description
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
                            type: KnownSeries.bloodPressureSystolic.rawValue
                        ),
                        VitalMeasurement(
                            date: correlation.startDate,
                            value: diastolic,
                            type: KnownSeries.bloodPressureDiastolic.rawValue
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
                return (HKUnit.pound(), "lbs")   // Dummy value
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
                return (HKUnit.pound(), "lbs")   // Dummy value
            }
            
            return identifiedUnits
        }
        
        private func getUnitsFor(identifier: String) -> (HKUnit, String)? {
            switch identifier {
            case HKQuantityTypeIdentifier.bodyMass.rawValue:
                self.formatter = { String(format: "%.1f", $0.first(where: { $0.0 == identifier })?.1 ?? 0) }
                return (Locale.current.measurementSystem == .us ? HKUnit.pound() : HKUnit.gramUnit(with: .kilo), "lbs")
            case HKQuantityTypeIdentifier.heartRate.rawValue:
                self.formatter = { "\(Int($0.first(where: { $0.0 == identifier })?.1 ?? 0))" }
                return (HKUnit.count().unitDivided(by: .minute()), "BPM")
            case HKCorrelationTypeIdentifier.bloodPressure.rawValue:
                self.formatter = {
                    [
                        "\(Int($0.first(where: { $0.0 == KnownSeries.bloodPressureSystolic.rawValue })?.1 ?? 0))",
                        "\(Int($0.first(where: { $0.0 == KnownSeries.bloodPressureDiastolic.rawValue })?.1 ?? 0))"
                    ].joined(separator: "/")
                }
                return (HKUnit.millimeterOfMercury(), "mmHg")
            default:
                return nil
            }
        }
    }
}
