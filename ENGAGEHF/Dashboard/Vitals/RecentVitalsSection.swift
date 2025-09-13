//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import HealthKit
import Spezi
@_spi(TestingSupport) import SpeziDevices
import SwiftUI


struct RecentVitalsSection: View {
    @Environment(NavigationManager.self) private var navigationManager
    @Environment(VitalsManager.self) private var vitalsManager
    @Environment(HealthMeasurements.self) private var measurements

    
    private var massUnits: HKUnit {
        switch Locale.current.measurementSystem {
        case .us:
            HKUnit.pound()
        default:
            HKUnit.gramUnit(with: .kilo)
        }
    }
    
    @MainActor private var weightMeasurement: (value: String, date: String)? {
        guard let measurement = vitalsManager.latestWeight else {
            return nil
        }
        
        return (
            String(format: "%.1f", measurement.quantity.doubleValue(for: massUnits)),
            measurement.startDate.formatted(date: .numeric, time: .shortened)
        )
    }
    
    @MainActor private var heartRateMeasurement: (value: String, date: String)? {
        guard let measurement = vitalsManager.latestHeartRate else {
            return nil
        }
        
        return (
            Int(measurement.quantity.doubleValue(for: .count().unitDivided(by: .minute()))).description,
            measurement.startDate.formatted(date: .numeric, time: .shortened)
        )
    }
    
    @MainActor private var bloodPressureMeasurement: (value: String, date: String)? {
        guard let measurement = vitalsManager.latestBloodPressure else {
            return nil
        }
        
        return (
            self.getBloodPressureDisplay(bloodPressureSample: measurement),
            measurement.startDate.formatted(date: .numeric, time: .shortened)
        )
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
                        .onTapGesture {
                            navigationManager.selectedTab = .heart
                            navigationManager.heartHealthVitalSelection = .weight
                        }
                        VitalsCard(
                            type: "Heart Rate",
                            units: "BPM",
                            measurement: heartRateMeasurement
                        )
                        .onTapGesture {
                            navigationManager.selectedTab = .heart
                            navigationManager.heartHealthVitalSelection = .heartRate
                        }
                    }
                    VitalsCard(
                        type: "Blood Pressure",
                        units: "mmHg",
                        measurement: bloodPressureMeasurement
                    )
                    .onTapGesture {
                        navigationManager.selectedTab = .heart
                        navigationManager.heartHealthVitalSelection = .bloodPressure
                    }
                }
            },
            header: {
                HStack {
                    Text("Recent Vitals")
                        .studyApplicationHeaderStyle()
                    Spacer()
                    if !measurements.pendingMeasurements.isEmpty {
                        Button("Review", systemImage: "heart.text.square") {
                            measurements.shouldPresentMeasurements = true
                        }
                    }
                }
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
        
        guard let systolic, let diastolic else {
            return "ERROR"
        }
        
        return "\(Int(systolic.quantity.doubleValue(for: .millimeterOfMercury())))/\(Int(diastolic.quantity.doubleValue(for: .millimeterOfMercury())))"
    }
}


#Preview {
    RecentVitalsSection()
        .previewWith(standard: ENGAGEHFStandard()) {
            VitalsManager()
            HealthMeasurements(mock: [.weight(.mockWeighSample)])
        }
}
