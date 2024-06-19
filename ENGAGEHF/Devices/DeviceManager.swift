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
    @MainActor private(set) var pairableDevice: (any OmronHealthDevice)? // TODO: react on advertisement disappearing?
    // TODO: implement as array to support multiple at the same time! (carousel vs Grid?)
    // TODO: get notified about disconnects! (=> pairing error!)

    @AppStorage("pairedDevices") @ObservationIgnored private var _pairedDevices: [PairedDeviceInfo] = []
    @MainActor var pairedDevices: [PairedDeviceInfo] {
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


    @MainActor var scanningNearbyDevices: Bool {
        pairedDevices.isEmpty || presentingDevicePairing
    }

    @MainActor
    func nearbyPairableDevice<Device: OmronHealthDevice>(_ device: Device) {
        guard !pairedDevices.contains(where: { $0.id == device.id }) else {
            return
        }

        self.pairableDevice = device
        presentingDevicePairing = true
    }


    @MainActor
    func registerPairedDevice<Device: OmronHealthDevice>(_ device: Device) {
        // TODO: let omronManufacturerData = device.manufacturerData?.users.first?.sequenceNumber (which user to choose from?)
        let deviceInfo = PairedDeviceInfo(
            id: device.id,
            name: device.label,
            model: device.model,
            icon: device.icon,
            batteryPercentage: device.battery.batteryLevel
        )

        pairedDevices.append(deviceInfo)
        if pairableDevice?.id == device.id {
            pairableDevice = nil
        }
    }

    @MainActor
    func handleDiscardedDevice<Device: OmronHealthDevice>(_ device: Device) {
        if pairableDevice?.id == device.id {
            pairableDevice = nil
        }
    }

    @MainActor
    func forgetDevice(id: UUID) {
        pairedDevices.removeAll { info in
            info.id == id
        }
    }

    @MainActor
    func updateBattery<Device: OmronHealthDevice>(for device: Device, percentage: UInt8) {
        guard let index = pairedDevices.firstIndex(where: { $0.id == device.id }) else {
            return
        }
        pairedDevices[index].lastBatteryPercentage = percentage
    }
}
