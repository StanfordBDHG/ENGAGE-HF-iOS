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
            Group {
                if !dosageInformation.currentSchedule.isEmpty && !dosageInformation.currentDailyIntake.isZero {
                    ScheduleSummary(
                        schedule: dosageInformation.currentSchedule,
                        unit: dosageInformation.unit,
                        label: "Current Dose:"
                    )
                } else {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Current Dose:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("Not Started")
                    }
                }
            }
                .padding(.bottom, 4)
            
            ScheduleSummary(
                schedule: dosageInformation.targetSchedule,
                unit: dosageInformation.unit,
                label: "Target Dose:"
            )
                .padding(.bottom, 4)
        }
    }
}


#Preview {
    TextualDosageSummary(
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
