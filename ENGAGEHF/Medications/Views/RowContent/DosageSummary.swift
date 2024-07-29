//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct DosageSummary: View {
    let dosageInformation: DosageInformation
    
    
    var body: some View {
        VStack {
            TextualDosageSummary(dosageInformation: dosageInformation)
                .padding(.vertical, 2)
            DosageGauge(dosageInformation: dosageInformation)
                .padding(.vertical, 2)
        }
    }
}


#Preview {
    DosageSummary(
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
