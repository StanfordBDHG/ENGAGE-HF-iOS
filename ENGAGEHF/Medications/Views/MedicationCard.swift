//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct MedicationCard: View {
    let medication: MedicationDetails
    
    @State private var isExpanded = false
    
    
    var body: some View {
        VStack {
            MedicationRowLabel(medication: medication, isExpanded: $isExpanded)
            
            if isExpanded {
                Divider()
                MedicationRowContent(medication: medication)
            }
        }
    }
}


#Preview {
    MedicationCard(
        medication: MedicationDetails(
            id: "test2",
            title: "Lozinopril",
            subtitle: "Beta Blocker",
            description: "Long description goes here",
            type: .improvementAvailable,
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
