//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct RecommendationSummary: View {
    let medication: MedicationDetails
    
    
    var body: some View {
        HStack {
            MedicationRecommendationSymbol(type: medication.type)
            VStack(alignment: .leading) {
                Text(medication.title)
                    .font(.headline)
                Text(medication.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}


#Preview {
    RecommendationSummary(
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
        )
    )
}
