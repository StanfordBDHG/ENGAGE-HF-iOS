//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct MedicationsList: View {
    private let viewModel: ViewModel
    
    
    var body: some View {
        if viewModel.containsRecommendations {
            List {
                if !viewModel.currentlyTakenMedications.isEmpty {
                    Section(
                        content: {
                            ForEach(viewModel.currentlyTakenMedications.sorted(by: { $0.type > $1.type })) { medication in
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
                            Text("Current Medications")
                        }
                    )
                }
                if !viewModel.notCurrentlyTakenMedications.isEmpty {
                    Section(
                        content: {
                            ForEach(viewModel.notCurrentlyTakenMedications.sorted(by: { $0.type > $1.type })) { medication in
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
                            Text("Medications That May Help")
                        }
                    )
                }
            }
                .expandableCardListStyle()
                .headerProminence(.increased)
        } else {
            ContentUnavailableView("No medication recommendations", systemImage: "pill.fill")
                .background(Color(.systemGroupedBackground))
        }
    }
    
    
    init(medications: [MedicationDetails]) {
        self.viewModel = ViewModel(medications)
    }
}


#Preview {
    MedicationsList(
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
        .previewWith(standard: ENGAGEHFStandard()) {
            MedicationsManager()
            NavigationManager()
        }
}
