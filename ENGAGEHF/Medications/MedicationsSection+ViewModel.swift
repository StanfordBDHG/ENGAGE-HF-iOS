//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


extension MedicationSection {
    class ViewModel {
        let header: String
        let medications: [MedicationDetails]
        let colorLegendEntries: [MedicationsLegendEntry]
        
        
        init(header: String, medications: [MedicationDetails]) {
            self.header = header
            self.medications = medications
            
            var entries: [MedicationsLegendEntry] = []
            for medication in medications {
                let newEntry = MedicationsLegendEntry(for: medication.type)
                if !entries.contains([newEntry]) {
                    entries.append(newEntry)
                }
            }
            self.colorLegendEntries = entries
        }
    }
}
