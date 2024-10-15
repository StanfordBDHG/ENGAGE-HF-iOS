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
        Section(
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
