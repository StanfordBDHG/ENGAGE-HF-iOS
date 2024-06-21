//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


struct PairedDeviceInfo { // TODO: observable and editable?
    let id: UUID
    let deviceType: String
    let icon: ImageReference?
    let model: String?

    var name: String
    var lastSeen: Date
    var lastBatteryPercentage: UInt8?
    var lastSequenceNumber: UInt16?
    var userDatabaseNumber: UInt32? // TODO: default value?
    // TODO: consent code?
    // TODO: last transfer time?
    // TODO: handle extensibility?

    init<Model: RawRepresentable>(
        id: UUID,
        deviceType: String,
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
            deviceType: deviceType,
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
        deviceType: String,
        name: String,
        model: String?,
        icon: ImageReference?,
        lastSeen: Date = .now,
        batteryPercentage: UInt8? = nil,
        lastSequenceNumber: UInt16? = nil,
        userDatabaseNumber: UInt32? = nil
    ) {
        self.id = id
        self.deviceType = deviceType
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


#if DEBUG
extension PairedDeviceInfo {
    static var mockBP5250: PairedDeviceInfo {
        PairedDeviceInfo(
            id: UUID(),
            deviceType: BloodPressureCuffDevice.deviceTypeIdentifier,
            name: "BP5250",
            model: OmronModel.bp5250,
            icon: .asset("Omron-BP5250")
        )
    }

    static var mockSC150: PairedDeviceInfo {
        PairedDeviceInfo(
            id: UUID(),
            deviceType: WeightScaleDevice.deviceTypeIdentifier,
            name: "SC-150",
            model: OmronModel.sc150,
            icon: .asset("Omron-SC-150")
        )
    }

    static var mockHealthDevice1: PairedDeviceInfo {
        PairedDeviceInfo(
            id: UUID(),
            deviceType: "HealthDevice1",
            name: "Health Device 1",
            model: "HD1",
            icon: nil
        )
    }

    static var mockHealthDevice2: PairedDeviceInfo {
        PairedDeviceInfo(
            id: UUID(),
            deviceType: "HealthDevice2",
            name: "Health Device 2",
            model: "HD2",
            icon: nil
        )
    }
}
#endif
