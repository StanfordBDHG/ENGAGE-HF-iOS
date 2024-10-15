//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


enum RecommendationSymbolColor {
    static func color(for type: MedicationRecommendationType) -> Color {
        switch type {
        case .targetDoseReached: .green
        case .personalTargetDoseReached: .green
        case .improvementAvailable: .yellow
        case .moreLabObservationsRequired: .yellow
        case .morePatientObservationsRequired: .yellow
        case .noActionRequired: .blue
        case .notStarted: .blue
        }
    }
    
    static func interpretation(for type: MedicationRecommendationType) -> String {
        switch type {
        case .targetDoseReached: "You're on your target dose."
        case .personalTargetDoseReached: "You're on your target dose."
        case .improvementAvailable: "On the med but may benefit from a higher dose."
        case .moreLabObservationsRequired: "On the med but may benefit from a higher dose."
        case .morePatientObservationsRequired: "On the med but may benefit from a higher dose."
        case .noActionRequired: "Not on this med that may help your heart"
        case .notStarted: "Not on this med that may help your heart"
        }
    }
}
