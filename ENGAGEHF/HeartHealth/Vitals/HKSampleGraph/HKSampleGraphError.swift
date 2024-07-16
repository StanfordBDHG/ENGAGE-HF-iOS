//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


enum HKSampleGraphError: LocalizedError {
    case unknownHKSample
    case failedToFetchUnits
    
    var errorDescription: String? {
        switch self {
        case .unknownHKSample: String(localized: "Failed to identify HKSample concrete subclass.")
        case .failedToFetchUnits: String(localized: "Failed to fetch HKUnits for the given samples.")
        }
    }
}
