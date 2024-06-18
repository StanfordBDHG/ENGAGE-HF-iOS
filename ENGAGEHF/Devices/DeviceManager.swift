//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI


struct OmronModel: RawRepresentable {
    let rawValue: String

    init(_ model: String) {
        self.init(rawValue: model)
    }

    init(rawValue: String) {
        self.rawValue = rawValue
    }
}


extension OmronModel {
    static let sc150 = OmronModel("SC150")
    static let bp5250 = OmronModel("BP5250")
}


extension OmronModel: Codable {
    init(from decoder: any Decoder) throws {
        let decoder = try decoder.singleValueContainer()
        self.rawValue = try decoder.decode(String.self)
    }

    func encode(to encoder: any Encoder) throws {
        var encoder = encoder.singleValueContainer()
        try encoder.encode(rawValue)
    }
}



struct PairedDevice: Codable, Identifiable {
    let id: UUID
    let name: String // TODO: customization?
    let model: OmronModel
    let lastSequenceNumber: UInt16?
    let userDatabaseNumber: UInt32? // TODO: default value?

    // TODO: store device type (e.g., for visuals!)
}


@Observable
class DeviceManager: Module, EnvironmentAccessible {

    @AppStorage("pairedDevices") @ObservationIgnored private var _pairedDevices: [PairedDevice] = []


    @MainActor var presentingDevicePairing = false
    @MainActor private(set) var pairableDevice: BloodPressureCuffDevice?

    @MainActor private(set) var pairedDevices: [PairedDevice] {
        get {
            access(keyPath: \.pairedDevices)
            return _pairedDevices
        }
        set {
            withMutation(keyPath: \.pairedDevices) {
                _pairedDevices = newValue
            }
        }
    }

    @MainActor
    func nearbyPairableDevice(_ device: BloodPressureCuffDevice) {
        pairableDevice = device
        presentingDevicePairing = true
    }


    @MainActor
    func registerPairedDevice<Device: HealthDevice>(_ device: Device) {
        // TODO: let omronManufacturerData = device.manufacturerData?.users.first?.sequenceNumber (which user to choose from?)
        let deviceDescription = PairedDevice(id: device.id, name: device.label, model: device.model, lastSequenceNumber: nil, userDatabaseNumber: nil)
        pairedDevices.append(deviceDescription)
    }

    @MainActor
    func clearPairableDevice() {
        pairableDevice = nil
    }
}

