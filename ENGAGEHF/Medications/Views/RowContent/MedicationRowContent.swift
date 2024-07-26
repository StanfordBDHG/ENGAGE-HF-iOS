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
            Text(medication.description)
                .font(.body)
                .padding(.vertical, 2)
            
            Button(action: {}) {
                Image(systemName: "questionmark.circle")
                    .accessibilityLabel("\(medication.title) More Information")
            }
                .frame(maxWidth: .infinity, alignment: .trailing)
            
            if let dosageInformation = medication.dosageInformation {
                Divider()
                CurrentDosageSummary(dosageInformation: dosageInformation)
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
                doses: [Dose(current: 50, minimum: 0, target: 100)],
                unit: "mg"
            )
        )
    )
}
