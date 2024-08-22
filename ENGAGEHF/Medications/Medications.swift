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
            MedicationsList(medications: medicationsManager.medications)
                .navigationTitle("Medications")
                .toolbar {
                    if AccountButton.shouldDisplay {
                        AccountButton(isPresented: $presentingAccount)
                    }
                }
#if DEBUG || TEST
                .toolbar {
                    if FeatureFlags.setupTestMedications {
                        ToolbarItem(placement: .secondaryAction) {
                            Button("Add Medications", systemImage: "heart.text.square") {
                                medicationsManager.injectTestMedications()
                            }
                        }
                    }
                }
#endif
        }
    }
}


#Preview {
    Medications(presentingAccount: .constant(false))
        .previewWith(standard: ENGAGEHFStandard()) {
            MedicationsManager()
        }
}
