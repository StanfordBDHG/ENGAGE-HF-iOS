//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct MedicationRecommendationSymbol: View {
    let type: MedicationRecommendationType
    
    
    private var labelSystemName: String {
        switch type {
        case .targetDoseReached: "checkmark.circle.fill"
        case .personalTargetDoseReached: "checkmark.circle.fill"
        case .improvementAvailable: "arrow.up.circle.fill"
        case .moreLabObservationsRequired: "circle.fill"
        case .morePatientObservationsRequired: "circle.fill"
        case .noActionRequired: "circle.fill"
        case .notStarted: "arrow.up.circle.fill"
        }
    }
    
    private var labelColor: Color {
        switch type {
        case .targetDoseReached: .green
        case .personalTargetDoseReached: .green
        case .improvementAvailable: .yellow
        case .moreLabObservationsRequired: .yellow
        case .morePatientObservationsRequired: .yellow
        case .noActionRequired: .gray
        case .notStarted: .gray
        }
    }
    
    
    var body: some View {
        Image(systemName: labelSystemName)
            .resizable()
            .frame(width: 40, height: 40)
            .foregroundStyle(labelColor)
    }
}


#Preview {
    MedicationRecommendationSymbol(type: .targetDoseReached)
}
