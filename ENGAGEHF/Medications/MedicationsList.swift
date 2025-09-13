//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI
import Spezi


struct MedicationsList: View {
    let containsRecommendations: Bool
    let currentlyTakenMedications: [MedicationDetails]
    let notCurrentlyTakenMedications: [MedicationDetails]
    
    
    var body: some View {
        if containsRecommendations {
            List {
                if !currentlyTakenMedications.isEmpty {
                    MedicationSection(header: "Current Medications", medications: currentlyTakenMedications)
                }
                if !notCurrentlyTakenMedications.isEmpty {
                    MedicationSection(header: "Medications That May Help", medications: notCurrentlyTakenMedications)
                }
                ColorLegend()
            }
                .expandableCardListStyle()
                .headerProminence(.increased)
        } else {
            ContentUnavailableView("No medication recommendations", systemImage: "pill.fill")
                .background(Color(.systemGroupedBackground))
        }
    }
    
    
    init(medications: [MedicationDetails]) {
        // A medication is marked as currently being taken if it contains a non-zero dosage schedule.
        self.currentlyTakenMedications = medications.filter { !$0.dosageInformation.currentDailyIntake.isZero }
        
        // A medication is marked as not currenlty being taken if it does not contain a dosage schedule.
        self.notCurrentlyTakenMedications = medications.filter { $0.dosageInformation.currentDailyIntake.isZero }
        
        // Flag for easily determining whether the ViewModel is empty or not.
        self.containsRecommendations = !self.currentlyTakenMedications.isEmpty || !self.notCurrentlyTakenMedications.isEmpty
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
