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


struct PairedDeviceInfo { // TODO: observable and editable?
    let id: UUID
    let model: String // TODO: we don't really need to store the model?
    let icon: ImageReference?
    
    var name: String // TODO: customization?
    var lastSeen: Date // TODO: update!
    var lastBatteryPercentage: UInt8?
    var lastSequenceNumber: UInt16?
    var userDatabaseNumber: UInt32? // TODO: default value?
    // TODO: connected?
    // TODO: consent code?
    // TODO: last transfer time?

    init<Model: RawRepresentable>(
        id: UUID,
        name: String,
        model: Model,
        icon: ImageReference?,
        lastSeen: Date = .now,
        batteryPercentage: UInt8? = nil,
        lastSequenceNumber: UInt16? = nil,
        userDatabaseNumber: UInt32? = nil
    ) where Model.RawValue == String {
        self.init(
            id: id,
            name: name,
            model: model.rawValue,
            icon: icon,
            lastSeen: lastSeen,
            batteryPercentage: batteryPercentage,
            lastSequenceNumber: lastSequenceNumber,
            userDatabaseNumber: userDatabaseNumber
        )
    }

    init(
        id: UUID,
        name: String,
        model: String,
        icon: ImageReference?,
        lastSeen: Date = .now,
        batteryPercentage: UInt8? = nil,
        lastSequenceNumber: UInt16? = nil,
        userDatabaseNumber: UInt32? = nil
    ) {
        self.id = id
        self.name = name
        self.model = model
        self.icon = icon
        self.lastSeen = lastSeen
        self.lastBatteryPercentage = batteryPercentage
        self.lastSequenceNumber = lastSequenceNumber
        self.userDatabaseNumber = userDatabaseNumber
    }
}


extension PairedDeviceInfo: Identifiable, Codable {}


extension PairedDeviceInfo: Hashable {
    // TODO: EQ implementation?
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
