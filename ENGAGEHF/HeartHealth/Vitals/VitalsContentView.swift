//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import SwiftUI


struct VitalsContentView: View {
    @Environment(VitalsManager.self) private var vitalsManager
    var vitalsType: VitalsType
    
    
    @MainActor private var listDisplayData: [VitalListMeasurement] {
        getDisplayInfo(for: vitalsType)
    }
    
    
    var body: some View {
        VitalsGraphSection(vitalsType: vitalsType)
        DescriptionSection(
            localizedExplanation: vitalsType.localizedExplanation,
            quantityName: vitalsType.description
        )
        MeasurementListSection(
            data: listDisplayData,
            units: vitalsType.unit.description,
            type: vitalsType.graphType
        )
    }
    
    
    init(for vitals: VitalsType) {
        self.vitalsType = vitals
    }
    

    @MainActor
    private func getDisplayInfo(for vital: VitalsType) -> [VitalListMeasurement] {
        let data: [HKSample] = switch vital {
        case .weight: vitalsManager.weightHistory
        case .heartRate: vitalsManager.heartRateHistory
        case .bloodPressure: vitalsManager.bloodPressureHistory
        }
        
        return data
            .map { sample in
                VitalListMeasurement(
                    id: sample.externalID,
                    value: getDisplayQuantity(sample: sample, type: vital),
                    date: sample.startDate
                )
            }
            .sorted {
                $0.date > $1.date
            }
    }
    
    private func getDisplayQuantity(sample: HKSample, type: VitalsType) -> String {
        let doubleValues = sample.getDoubleValues(for: type.unit.hkUnit)
        
        guard !doubleValues.isEmpty else {
            return "---"
        }
        
        switch type {
        case .weight:
            guard let weight = doubleValues[HKQuantityTypeIdentifier.bodyMass.rawValue] else {
                return "---"
            }
            return String(format: "%.1f", weight)
        case .heartRate:
            guard let heartRate = doubleValues[HKQuantityTypeIdentifier.heartRate.rawValue] else {
                return "---"
            }
            return Int(heartRate).description
        case .bloodPressure:
            guard let systolic = doubleValues[HKQuantityTypeIdentifier.bloodPressureSystolic.rawValue],
                  let diastolic = doubleValues[HKQuantityTypeIdentifier.bloodPressureDiastolic.rawValue] else {
                return "---"
            }
            
            return "\(Int(systolic))/\(Int(diastolic))"
        }
    }
}


#Preview {
    VitalsContentView(for: .weight)
}
