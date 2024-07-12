//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


enum HeartHealthError: LocalizedError {
    case invalidDate(Date)
    case failedDeletion
    
    var errorDescription: String? {
        switch self {
        case .invalidDate(let date): String(localized: "Unable to create time interval for date: \(date.formatted())")
        case .failedDeletion: String(localized: "Unable to delete measurement, check network connection.")
        }
    }
}
