//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct DosageGauge: View {
    let dosageInformation: DosageInformation
    
    private let minimumDailyIntake: Double = 0
    
    
    private var clampedCurrentDailyIntake: Double {
        let current = dosageInformation.currentDailyIntake
        let minimum = minimumDailyIntake
        let target = dosageInformation.targetDailyIntake
        
        if current < minimum {
            return minimum
        }
        if current > target {
            return target
        }
        return current
    }
    
    private var dosageRange: ClosedRange<Double> {
        minimumDailyIntake...dosageInformation.targetDailyIntake
    }
    
    
    var body: some View {
        Gauge(value: clampedCurrentDailyIntake, in: dosageRange) {
            // No overall label
        } currentValueLabel: {
            Text("Current")
                .foregroundStyle(.accent)
                .font(.caption)
        } minimumValueLabel: {
            // No minimum label
            Text("")
        } maximumValueLabel: {
            Text("Target")
                .foregroundStyle(.secondary)
                .font(.caption)
        }
            .gaugeStyle(DosageGaugeStyle(currentLabelAlignment: .leading))
    }
}


#Preview {
    DosageGauge(
        dosageInformation: DosageInformation(
            currentSchedule: [
                DoseSchedule(frequency: 2, quantity: [25]),
                DoseSchedule(frequency: 1, quantity: [15])
            ],
            minimumSchedule: [
                DoseSchedule(frequency: 2, quantity: [5]),
                DoseSchedule(frequency: 1, quantity: [2.5])
            ],
            targetSchedule: [
                DoseSchedule(frequency: 2, quantity: [50]),
                DoseSchedule(frequency: 1, quantity: [25])
            ],
            unit: "mg"
        )
    )
}
