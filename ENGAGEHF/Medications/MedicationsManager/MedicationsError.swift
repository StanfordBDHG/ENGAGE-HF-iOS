//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


enum MedicationsError: LocalizedError {
    case failedToFetchRecommendedMedication
    case noDisplayName
    
    var errorDescription: String? {
        switch self {
        case .failedToFetchRecommendedMedication: String(localized: "Failed to fetch recommended medication.")
        case .noDisplayName: String(localized: "No display name present.")
        }
    }
}
