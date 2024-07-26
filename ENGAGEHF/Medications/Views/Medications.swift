//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct Medications: View {
    @Binding var presentingAccount: Bool
    
    @Environment(MedicationsManager.self) private var medicationsManager
    
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(medicationsManager.medications) { medication in
                    MedicationCard(medication: medication)
                }
            }
                .listRowSeparator(.hidden)
                .listRowSpacing(4)
                .navigationTitle("Medications")
        }
    }
}


#Preview {
    Medications(presentingAccount: .constant(false))
        .previewWith(standard: ENGAGEHFStandard()) {
            MedicationsManager()
        }
}
