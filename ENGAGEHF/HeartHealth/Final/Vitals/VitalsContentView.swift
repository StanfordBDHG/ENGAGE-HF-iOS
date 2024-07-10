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
    
    
    private var listDisplayData: [VitalMeasurement] {
        getDisplayInfo(for: vitalsType)
    }
    
    private var hkUnit: String {
        switch vitalsType {
        case .weight: Locale.current.measurementSystem == .us ? "lb" : "kg"
        case .heartRate: "count/min"
        case .bloodPressure: "mmHg"
        }
    }
    
    private var displayUnit: String {
        switch vitalsType {
        case .weight: Locale.current.measurementSystem == .us ? "lb" : "kg"
        case .heartRate: "BPM"
        case .bloodPressure: "mmHg"
        }
    }
    
    
    var body: some View {
        VitalsGraphSection()
        DescriptionSection(explanationKey: vitalsType.explanationKey)
        SymptomsListSection(
            data: listDisplayData,
            units: displayUnit,
            type: vitalsType.graphType
        )
    }
    
    
    init(for vitals: VitalsType) {
        self.vitalsType = vitals
    }
    
    
    private func getDisplayInfo(for vital: VitalsType) -> [VitalMeasurement] {
        let data: [HKSample] = switch vital {
        case .weight: vitalsManager.weightHistory
        case .heartRate: vitalsManager.heartRateHistory
        case .bloodPressure: vitalsManager.bloodPressureHistory
        }
        
        return data
            .map { sample in
                VitalMeasurement(
                    id: sample.externalUUID?.uuidString,
                    value: getDisplayQuantity(sample: sample, type: vitalsType, units: hkUnit),
                    date: sample.date
                )
            }
            .sorted {
                $0.date > $1.date
            }
    }
    
    private func getDisplayQuantity(sample: HKSample, type: VitalsType, units: String) -> String {
        let doubleValues = sample.getDoubleValues(for: units)
        
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
