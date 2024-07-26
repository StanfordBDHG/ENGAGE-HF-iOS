//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct MedicationCard: View {
    let medication: MedicationDetails
    
    @State private var isExpanded = false
    
    
    var body: some View {
        VStack {
            MedicationRowLabel(medication: medication, isExpanded: $isExpanded)
            
            if isExpanded {
                Divider()
                MedicationRowContent(medication: medication)
            }
        }
    }
}


#Preview {
    MedicationCard(
        medication: MedicationDetails(
            id: "test1",
            title: "Lorem",
            subtitle: "Ipsum",
            description: "Description ",
            type: .targetDoseReached,
            dosageInformation: DosageInformation(
                doses: [
                    Dose(current: 67.3, minimum: 24.0, target: 100.0),
                    Dose(current: 42.3, minimum: 12.0, target: 50.0)
                ],
                unit: "mg"
            )
        )
    )
}
