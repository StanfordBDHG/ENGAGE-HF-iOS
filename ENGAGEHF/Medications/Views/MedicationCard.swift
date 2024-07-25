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
    
    
    private var displayCurrentDosage: String {
        medication.doses.map({ String(format: "%.1f", $0.current) }).joined(separator: "/") + " " + (medication.doses.first?.unit ?? "")
    }
    
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                MedicationRecommendationSymbol(type: medication.type)
                VStack(alignment: .leading) {
                    Text(medication.title)
                        .font(.headline)
                    Text(medication.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            Text(medication.description)
                .font(.body)
                .padding(.top, 2)
            
            Text(displayCurrentDosage)
        }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(radius: 2)
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
            doses: [
                Dose(current: 67.3, minimum: 24.0, target: 100.0, unit: "mg"),
                Dose(current: 42.3, minimum: 12.0, target: 50.0, unit: "mg")
            ]
        )
    )
}
