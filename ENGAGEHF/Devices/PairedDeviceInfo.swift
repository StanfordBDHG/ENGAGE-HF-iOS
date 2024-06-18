//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation

// TODO: DeviceManager (provide a list of Model numbers and associated UI (and default names?)
// TODO: but there is device-specific data?


struct PairedDeviceInfo: Codable, Identifiable {
    let id: UUID
    let name: String // TODO: customization?
    let model: OmronModel
    let lastSequenceNumber: UInt16?
    let userDatabaseNumber: UInt32? // TODO: default value?

    // TODO: store device type (e.g., for visuals!)
}

// TODO: sensor.fill as generic icon!
