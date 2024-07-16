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
    var granularity: DateGranularity
    
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
    
    private var graphData: [VitalGraphMeasurement] {
        data.compactMap { measurement in
            switch measurement {
            case let quantitySample as HKQuantitySample:
                return VitalGraphMeasurement(
                    date: quantitySample.startDate,
                    value: quantitySample.quantity.doubleValue(for: units)
                )
            case let correlation as HKCorrelation:
                // TODO: Handle multiple quantity types (i.e. plot multiple series on the same chart)
                // This will involve being safer with type names, so using a dictionary mapping enumed keys to series values
                let doubleValues = correlation.getDoubleValues(for: units.unitString)
                guard let systolicValue = doubleValues.first else {
                    viewState = .error(HKSampleGraphError.failedToFetchUnits)
                    return nil
                }
                return VitalGraphMeasurement(
                    date: correlation.date,
                    value: systolicValue
                )
            default:
                return nil
            }
        }
    }
    
    
    var body: some View {
        VitalsGraph(
            data: graphData,
            granularity: granularity,
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
    HKSampleGraph(data: [], granularity: .daily)
}
