//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


enum PairingState {
    case discovery
    case pairing
    case paired(any OmronHealthDevice)
    case error(LocalizedError)
}
