//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


enum FetchingError: LocalizedError {
    case invalidTimestamp
    case userNotAuthenticated
    
    
    var errorDescription: String? {
        switch self {
        case .invalidTimestamp:
            String(localized: "Unable to get notification timestamp.", comment: "Invalid Timestamp")
        case .userNotAuthenticated:
            String(localized: "User not authenticated. Please sign in an try again.", comment: "User Not Authenticated")
        }
    }
}
