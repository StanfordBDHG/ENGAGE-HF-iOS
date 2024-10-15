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
                    MedicationSection(header: "Current Medications", medications: viewModel.currentlyTakenMedications)
                }
                if !viewModel.notCurrentlyTakenMedications.isEmpty {
                    MedicationSection(header: "Medications That May Help", medications: viewModel.notCurrentlyTakenMedications)
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
