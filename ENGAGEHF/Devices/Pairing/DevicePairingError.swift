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
        }
    }

    var failureReason: String? {
        switch self {
        case .invalidState:
            String(localized: "") // TODO: what is the message?
        case .busy:
            String(localized: "The device is busy and failed to complete pairing.")
        case .notInPairingMode:
            String(localized: "The device was not put into pairing mode.")
        }
    }
}


extension TimeoutError: LocalizedError { // TODO: eventually move to SpeziFoundation!
    public var errorDescription: String? {
        String(localized: "Timeout")
    }

    public var failureReason: String? {
        String(localized: "The operation timed out.")
    }
}
