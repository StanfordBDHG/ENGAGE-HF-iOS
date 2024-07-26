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
            Group {
                if !medicationsManager.medications.isEmpty {
                    List {
                        ForEach(medicationsManager.medications.sorted(by: { $0.type > $1.type })) { medication in
                            MedicationCard(medication: medication)
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowSpacing(8)
                } else {
                    ContentUnavailableView("No medication recommendations", systemImage: "pill.fill")
                        .symbolVariant(.slash)
                }
            }
                .navigationTitle("Medications")
                .toolbar {
                    if AccountButton.shouldDisplay {
                        AccountButton(isPresented: $presentingAccount)
                    }
                }
        }
    }
}


#Preview {
    Medications(presentingAccount: .constant(false))
        .previewWith(standard: ENGAGEHFStandard()) {
            MedicationsManager()
        }
}
