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
                if !medicationsManager.medications.isEmpty {
                    ForEach(medicationsManager.medications.sorted(by: { $0.type < $1.type })) { medication in
                        MedicationCard(medication: medication)
                    }
                } else {
                    EmptyMedicationsView()
                }
            }
                .listRowSeparator(.hidden)
                .listRowSpacing(8)
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
