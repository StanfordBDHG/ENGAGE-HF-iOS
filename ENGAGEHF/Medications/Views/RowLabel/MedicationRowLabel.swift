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
        ),
        isExpanded: .constant(false)
    )
}
