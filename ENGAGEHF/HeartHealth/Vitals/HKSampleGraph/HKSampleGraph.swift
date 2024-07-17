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
    
    private var units: HKUnit {
        guard let sample = data.first else {
            viewState = .error(HKSampleGraphError.failedToFetchUnits)
            return HKUnit.pound()   // Dummy value
        }
        
        let identifiedUnits: HKUnit?
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
            return HKUnit.pound()   // Dummy value
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
                        value: quantitySample.quantity.doubleValue(for: units),
                        type: quantitySample.quantityType.description
                    )
                ]
            case let correlation as HKCorrelation:
                // For now, just handling the case where the correlation is blood pressure
                let doubleValues = correlation.getDoubleValues(for: units.unitString)
                guard doubleValues.count == 2 else {
                    viewState = .error(HKSampleGraphError.failedToFetchUnits)
                    return []
                }
                return [
                    VitalMeasurement(
                        date: correlation.date,
                        value: doubleValues[0],
                        type: "Systolic"
                    ),
                    VitalMeasurement(
                        date: correlation.date,
                        value: doubleValues[1],
                        type: "Disatolic"
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
            displayUnit: units.localizedUnitString()
        )
            .viewStateAlert(state: $viewState)
    }
    
    
    private func getUnitsFor(identifier: String) -> HKUnit? {
        switch identifier {
        case HKQuantityTypeIdentifier.bodyMass.rawValue:
            return Locale.current.measurementSystem == .us ? HKUnit.pound() : HKUnit.gramUnit(with: .kilo)
        case HKQuantityTypeIdentifier.heartRate.rawValue:
            return HKUnit.count().unitDivided(by: .minute())
        case HKCorrelationTypeIdentifier.bloodPressure.rawValue:
            return HKUnit.millimeterOfMercury()
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
