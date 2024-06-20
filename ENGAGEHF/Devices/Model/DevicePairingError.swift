//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziFoundation


enum DevicePairingError {
    case invalidState
    /// The device is busy (e.g., already pairing).
    case busy
    /// The device is not in pairing mode.
    case notInPairingMode
    case deviceDisconnected
}


extension DevicePairingError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidState:
            String(localized: "Invalid State")
        case .busy:
            String(localized: "Device Busy")
        case .notInPairingMode:
            String(localized: "Not Ready")
        case .deviceDisconnected:
            String(localized: "Pairing Failed")
        }
    }

    var failureReason: String? {
        switch self {
        case .invalidState, .deviceDisconnected:
            String(localized: "Failed to pair with device. Please try again.")
        case .busy:
            String(localized: "The device is busy and failed to complete pairing.")
        case .notInPairingMode:
            String(localized: "The device was not put into pairing mode.")
        }
    }
}
