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
            videoPath: "videoSections/1/videos/2",
            type: .targetDoseReached,
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
    )
}
