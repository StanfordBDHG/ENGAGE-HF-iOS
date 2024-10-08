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
    let accessibilityTag: String
    
    
    var body: some View {
        VStack {
            TextualDosageSummary(dosageInformation: dosageInformation, accessibilityTag: accessibilityTag)
                .padding(.vertical, 2)
            DosageGauge(dosageInformation: dosageInformation)
                .padding(.vertical, 2)
                .accessibilityIdentifier("\(accessibilityTag) Dosage Gauge")
        }
    }
}


#Preview {
    DosageSummary(
        dosageInformation: DosageInformation(
            currentSchedule: [
                DoseSchedule(frequency: 2, quantity: [25]),
                DoseSchedule(frequency: 1, quantity: [15])
            ],
            targetSchedule: [
                DoseSchedule(frequency: 2, quantity: [50]),
                DoseSchedule(frequency: 1, quantity: [25])
            ],
            unit: "mg"
        ),
        accessibilityTag: "Carvedilol"
    )
}
