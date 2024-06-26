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
    
    private var weightMeasurement: (value: String, date: String)? {
        if let measurement = vitalsManager.latestWeight {
            return (
                String(format: "%.1f", measurement.quantity.doubleValue(for: massUnits)),
                measurement.startDate.formatted(date: .numeric, time: .shortened)
            )
        }
        return nil
    }
    
    private var heartRateMeasurement: (value: String, date: String)? {
        if let measurement = vitalsManager.latestHeartRate {
            return (
                Int(measurement.quantity.doubleValue(for: .count().unitDivided(by: .minute()))).description,
                measurement.startDate.formatted(date: .numeric, time: .shortened)
            )
        }
        return nil
    }
    
    private var bloodPressureMeasurement: (value: String, date: String)? {
        if let measurement = vitalsManager.latestBloodPressure {
            return (
                self.getBloodPressureDisplay(bloodPressureSample: measurement),
                measurement.startDate.formatted(date: .numeric, time: .shortened)
            )
        }
        return nil
    }
    
    
    var body: some View {
        Section(
            content: {
                VStack {
                    HStack {
                        VitalsCard(
                            type: "Weight",
                            units: massUnits.unitString,
                            measurement: weightMeasurement
                        )
                        VitalsCard(
                            type: "Heart Rate",
                            units: "BPM",
                            measurement: heartRateMeasurement
                        )
                    }
                    VitalsCard(
                        type: "Blood Pressure",
                        units: "mmHg",
                        measurement: bloodPressureMeasurement
                    )
                }
            },
            header: {
                Text("Recent Vitals")
                    .studyApplicationHeaderStyle()
            }
        )
    }
    
    
    private func getBloodPressureDisplay(bloodPressureSample: HKCorrelation) -> String {
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
            return "ERROR"
        }
    }
}


#Preview {
    RecentVitalsSection()
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
        }
}
