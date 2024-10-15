//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct MedicationSection: View {
    private let viewModel: ViewModel
    
    
    var body: some View {
        Section(
            content: {
                ForEach(viewModel.medications.sorted(by: { $0.type > $1.type })) { medication in
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
                Text(viewModel.header)
                    .padding(.horizontal, -16)
            },
            footer: {
                VStack(alignment: .leading) {
                    ForEach(viewModel.colorLegendEntries, id: \.self) { entry in
                        ColorKeyRow(color: entry.color, description: entry.description)
                    }
                }
                    .padding(.horizontal, -16)
            }
        )
    }
    
    
    init(header: String, medications: [MedicationDetails]) {
        self.viewModel = ViewModel(header: header, medications: medications)
    }
}
