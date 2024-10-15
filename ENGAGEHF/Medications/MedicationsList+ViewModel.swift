//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


extension MedicationsList {
    class ViewModel {
        let containsRecommendations: Bool
        
        let currentlyTakenMedications: [MedicationDetails]
        let notCurrentlyTakenMedications: [MedicationDetails]
        
        
        init(_ medications: [MedicationDetails]) {
            // A medication is marked as currently being taken if it contains a non-zero dosage schedule.
            self.currentlyTakenMedications = {
                medications.filter { !$0.dosageInformation.currentDailyIntake.isZero }
            }()
            
            // A medication is marked as not currenlty being taken if it does not contain a dosage schedule.
            self.notCurrentlyTakenMedications = {
                medications.filter { $0.dosageInformation.currentDailyIntake.isZero }
            }()
            
            // Flag for easily determining whether the ViewModel is empty or not.
            self.containsRecommendations = !self.currentlyTakenMedications.isEmpty || !self.notCurrentlyTakenMedications.isEmpty
        }
    }
}
