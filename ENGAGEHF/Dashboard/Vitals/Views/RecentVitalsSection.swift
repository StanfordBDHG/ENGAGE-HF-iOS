//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import SwiftUI


struct RecentVitalsSection: View {
    @Environment(VitalsManager.self) private var vitalsManager
    
    
    private var massUnits: HKUnit {
        switch Locale.current.measurementSystem {
        case .us:
            HKUnit.pound()
        default:
            HKUnit.gramUnit(with: .kilo)
        }
    }
    
    private var weightDescription: String? {
        if let weightMeasurement = vitalsManager.latestWeight {
            return String(format: "%.1f", weightMeasurement.quantity.doubleValue(for: massUnits))
        }
        return nil
    }
    
    private var heartRateDescription: String? {
        if let heartRateMeasurement = vitalsManager.latestHeartRate {
            return Int(heartRateMeasurement.quantity.doubleValue(for: .count().unitDivided(by: .minute()))).description
        }
        return nil
    }
    
    
    var body: some View {
        Section(
            content: {
                VStack {
                    HStack {
                        VitalsCard(
                            measurement: (
                                type: "Weight",
                                value: weightDescription
                            ),
                            units: massUnits.unitString,
                            date: vitalsManager.latestWeight?.startDate
                        )
                        VitalsCard(
                            measurement: (
                                type: "Heart Rate",
                                value: heartRateDescription
                            ),
                            units: "BPM",
                            date: vitalsManager.latestHeartRate?.startDate
                        )
                    }
                    VitalsCard(
                        measurement: (
                            type: "Blood Pressure",
                            value: self.getBloodPressureDisplay(bloodPressureSample: vitalsManager.latestBloodPressure)
                        ),
                        units: "mmHg",
                        date: vitalsManager.latestBloodPressure?.startDate
                    )
                }
            },
            header: {
                Text("Recent Vitals")
                    .studyApplicationHeaderStyle()
            }
        )
    }
    
    
    private func getBloodPressureDisplay(bloodPressureSample: HKCorrelation?) -> String? {
        guard let bloodPressureSample else {
            return nil
        }
        
        var bloodPressureQuantitySamples: [HKQuantitySample] {
            bloodPressureSample.objects
                .compactMap { sample in
                    sample as? HKQuantitySample
                }
        }
        
        var systolic: HKQuantitySample? {
            bloodPressureQuantitySamples
                .first(where: { $0.quantityType == HKQuantityType(.bloodPressureSystolic) })
        }
        var diastolic: HKQuantitySample? {
            bloodPressureQuantitySamples
                .first(where: { $0.quantityType == HKQuantityType(.bloodPressureDiastolic) })
        }
        
        if let systolic,
           let diastolic {
            return "\(Int(systolic.quantity.doubleValue(for: .millimeterOfMercury())))/\(Int(diastolic.quantity.doubleValue(for: .millimeterOfMercury())))"
        } else {
            return nil
        }
    }
}


#Preview {
    RecentVitalsSection()
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}
