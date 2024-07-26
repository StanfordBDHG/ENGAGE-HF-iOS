//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct MedicationRowContent: View {
    let medication: MedicationDetails
    
    
    var body: some View {
        VStack(alignment: .leading) {
            MedicationDescription(title: medication.title, description: medication.description)
                .padding(.vertical, 2)
            
            if let dosageInformation = medication.dosageInformation {
                Divider()
                DosageSummary(dosageInformation: dosageInformation)
            }
        }
    }
}


#Preview {
    MedicationRowContent(
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
