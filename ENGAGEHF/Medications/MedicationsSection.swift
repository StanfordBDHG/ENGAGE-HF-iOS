//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct MedicationSection: View {
    let header: String
    let medications: [MedicationDetails]
    
    
    var body: some View {
        ExpandableSection(
            content: {
                ForEach(medications.sorted(by: { $0.type > $1.type })) { medication in
                    ExpandableListCard(
                        label: {
                            RecommendationSummary(medication: medication)
                        },
                        content: {
                            MedicationRowContent(medication: medication)
                        }
                    )
                }
            },
            header: {
                Text(header)
                    .padding(.horizontal, -16)
            }
        )
    }
}


#Preview {
    List {
        MedicationSection(
            header: "Current Medications",
            medications: [
                MedicationDetails(
                    id: "test2",
                    title: "Lozinopril",
                    subtitle: "Beta Blocker",
                    description: "Long description goes here",
                    videoPath: "videoSections/1/videos/2",
                    type: .improvementAvailable,
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
                    )
                )
            ]
        )
    }
}
