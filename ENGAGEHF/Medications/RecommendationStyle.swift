//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// Defines the color and interpretation associated with a `MedicationRecommendation` in the UI.
enum RecommendationStyle: CaseIterable {
    case targetReached, improvementAvailable, notStarted
    
    
    var color: Color {
        switch self {
        case .targetReached: .green
        case .improvementAvailable: .yellow
        case .notStarted: .blue
        }
    }
    
    var localizedInterpretation: String {
        switch self {
        case .targetReached:
            String(localized: "You're on your target dose.", comment: "Target dose reached color legend entry.")
        case .improvementAvailable:
            String(localized: "On the med but may benefit from a higher dose.", comment: "Improvement available color legend entry.")
        case .notStarted:
            String(localized: "Not on this med that may help your heart.", comment: "No action required legend entry.")
        }
    }
}
