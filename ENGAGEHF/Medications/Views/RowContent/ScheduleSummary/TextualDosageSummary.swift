//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct TextualDosageSummary: View {
    let dosageInformation: DosageInformation
    
    
    var body: some View {
        VStack {
            CurrentScheduleSummary(currentSchedule: dosageInformation.currentSchedule, unit: dosageInformation.unit)
                .padding(.bottom, 2)
            HStack {
                Text("Target Daily Intake:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(dosageInformation.targetDailyIntake.asString() + " " + dosageInformation.unit)
            }
        }
    }
}


#Preview {
    TextualDosageSummary(
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
