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
    
    
    private var listDisplayData: [VitalListMeasurement] {
        getDisplayInfo(for: vitalsType)
    }
    
    
    var body: some View {
        VitalsGraphSection(vitalsType: vitalsType)
        DescriptionSection(
            explanationKey: vitalsType.explanationKey,
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
    
    
    private func getDisplayInfo(for vital: VitalsType) -> [VitalListMeasurement] {
        let data: [HKSample] = switch vital {
        case .weight: vitalsManager.weightHistory
        case .heartRate: vitalsManager.heartRateHistory
        case .bloodPressure: vitalsManager.bloodPressureHistory
        }
        
        return data
            .map { sample in
                VitalListMeasurement(
                    id: sample.externalUUID?.uuidString,
                    value: getDisplayQuantity(sample: sample, type: vital),
                    date: sample.date
                )
            }
            .sorted {
                $0.date > $1.date
            }
    }
    
    private func getDisplayQuantity(sample: HKSample, type: VitalsType) -> String {
        let doubleValues = sample.getDoubleValues(for: type.unit.hkUnitString)
        
        guard !doubleValues.isEmpty else {
            return "ERROR"
        }
        
        switch type {
        case .weight:
            guard let weight = doubleValues.first else {
                return "ERROR"
            }
            return String(format: "%.1f", weight)
        case .heartRate:
            guard let heartRate = doubleValues.first else {
                return "ERROR"
            }
            return Int(heartRate).description
        case .bloodPressure:
            guard doubleValues.count == 2 else {
                return "ERROR"
            }
            
            let systolic = Int(doubleValues[0])
            let diastolic = Int(doubleValues[1])
            
            return "\(systolic)/\(diastolic)"
        }
    }
}


#Preview {
    VitalsContentView(for: .weight)
}
