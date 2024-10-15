//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct MedicationsLegendEntry: Hashable, Equatable {
    let color: Color
    let description: String
    
    
    init(for type: MedicationRecommendationType) {
        self.color = RecommendationSymbolColor.color(for: type)
        self.description = RecommendationSymbolColor.interpretation(for: type)
    }
}
