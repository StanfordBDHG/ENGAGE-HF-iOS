//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI


@Observable
class DeviceManager: Module, EnvironmentAccessible {
    /// Determines if the device discovery sheet should be presented.
    @MainActor var presentingDevicePairing = false
    @MainActor private(set) var pairableDevice: (any OmronHealthDevice)?
    // TODO: implement as array to support multiple at the same time! (carousel vs Grid?)
    // TODO: get notified about disconnects! (=> pairing error!)

    @AppStorage("pairedDevices") @ObservationIgnored private var _pairedDevices: [PairedDeviceInfo] = []
    @MainActor private(set) var pairedDevices: [PairedDeviceInfo] {
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
    func nearbyPairableDevice<Device: OmronHealthDevice>(_ device: Device) {
        self.pairableDevice = device
        presentingDevicePairing = true
    }


    @MainActor
    func registerPairedDevice<Device: OmronHealthDevice>(_ device: Device) {
        // TODO: let omronManufacturerData = device.manufacturerData?.users.first?.sequenceNumber (which user to choose from?)
        let deviceDescription = PairedDeviceInfo(id: device.id, name: device.label, model: device.model, lastSequenceNumber: nil, userDatabaseNumber: nil)
        pairedDevices.append(deviceDescription)
    }

    @MainActor
    func clearPairableDevice() {
        pairableDevice = nil
    }
}

