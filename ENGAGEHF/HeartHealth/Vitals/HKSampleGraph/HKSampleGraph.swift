//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import SpeziViews
import SwiftUI


struct HKSampleGraph: View {
    var data: [HKSample]
    var dateRange: ClosedRange<Date>
    var dateResolution: Calendar.Component
    
    @State private var viewState: ViewState = .idle
    
    
    private var units: (hkUnit: HKUnit, display: String) {
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
    
    private var graphData: [VitalMeasurement] {
        data.flatMap { measurement in
            switch measurement {
            case let quantitySample as HKQuantitySample:
                return [
                    VitalMeasurement(
                        date: quantitySample.startDate,
                        value: quantitySample.quantity.doubleValue(for: units.hkUnit),
                        type: quantitySample.quantityType.description
                    )
                ]
            case let correlation as HKCorrelation:
                // For now, just handling the case where the correlation is blood pressure
                // getDoubleValues for an HKCorrelation returns the array: [systolicDoubleVal, diastolicDoubleVal]
                let doubleValues = correlation.getDoubleValues(for: units.hkUnit.unitString)
                guard doubleValues.count == 2 else {
                    viewState = .error(HKSampleGraphError.failedToFetchUnits)
                    return []
                }
                return [
                    VitalMeasurement(
                        date: correlation.date,
                        value: doubleValues[0],
                        type: String(describing: KnownSeries.bloodPressureSystolic)
                    ),
                    VitalMeasurement(
                        date: correlation.date,
                        value: doubleValues[1],
                        type: String(describing: KnownSeries.bloodPressureDiastolic)
                    )
                ]
            default:
                viewState = .error(HKSampleGraphError.unknownHKSample)
                return []
            }
        }
    }
    
    
    var body: some View {
        VitalsGraph(
            data: graphData,
            dateRange: dateRange,
            dateResolution: dateResolution,
            displayUnit: units.display
        )
            .viewStateAlert(state: $viewState)
    }
    
    
    private func getUnitsFor(identifier: String) -> (HKUnit, String)? {
        switch identifier {
        case HKQuantityTypeIdentifier.bodyMass.rawValue:
            return (Locale.current.measurementSystem == .us ? HKUnit.pound() : HKUnit.gramUnit(with: .kilo), "lbs")
        case HKQuantityTypeIdentifier.heartRate.rawValue:
            return (HKUnit.count().unitDivided(by: .minute()), "bpm")
        case HKCorrelationTypeIdentifier.bloodPressure.rawValue:
            return (HKUnit.millimeterOfMercury(), "mmHg")
        default:
            return nil
        }
    }
}


#Preview {
    HKSampleGraph(
        data: [],
        dateRange: Date()...Date(),
        dateResolution: .day
    )
}
