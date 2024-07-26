//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct MedicationRowLabel: View {
    let medication: MedicationDetails
    @Binding var isExpanded: Bool
    
    
    var body: some View {
        HStack {
            RecommendationSummary(medication: medication)
            Spacer()
            Image(systemName: "chevron.right")
                .accessibilityLabel("Medication Expansion Button")
                .foregroundStyle(.accent)
                .rotationEffect(.degrees(isExpanded ? 90 : 0))
                .animation(nil, value: isExpanded)
        }
        .contentShape(Rectangle())
        .onTapGesture { isExpanded.toggle() }
    }
}


#Preview {
    MedicationRowLabel(
        medication: MedicationDetails(
            id: "test1",
            title: "Lisinopril",
            subtitle: "Beta Blockers",
            description: "Description of the recommendation",
            type: .targetDoseReached,
            dosageInformation: DosageInformation(
                currentSchedule: [
                    DoseSchedule(timesDaily: 2, dose: 25),
                    DoseSchedule(timesDaily: 1, dose: 15)
                ],
                minimumDailyIntake: 10,
                targetDailyIntake: 70,
                unit: "mg"
            )
        ),
        isExpanded: .constant(false)
    )
}
