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
    
    
    private var clampedCurrentDailyIntake: Double {
        let current = dosageInformation.currentDailyIntake
        let minimum = dosageInformation.minimumDailyIntake
        let target = dosageInformation.targetDailyIntake
        
        if current < minimum {
            return minimum
        }
        if current > target {
            return target
        }
        return current
    }
    
    
    var body: some View {
        Gauge(
            value: clampedCurrentDailyIntake,
            in: dosageInformation.minimumDailyIntake...dosageInformation.targetDailyIntake,
            label: {},
            currentValueLabel: {},
            markedValueLabels: { Text(clampedCurrentDailyIntake.asString()) }
        )
    }
}


#Preview {
    DosageGauge(
        dosageInformation: DosageInformation(
            currentSchedule: [
                DoseSchedule(timesDaily: 2, dose: 25),
                DoseSchedule(timesDaily: 1, dose: 15)
            ],
            minimumDailyIntake: 10,
            targetDailyIntake: 70,
            unit: "mg"
        )
    )
}
