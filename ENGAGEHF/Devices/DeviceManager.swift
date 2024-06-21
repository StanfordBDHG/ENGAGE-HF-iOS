//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import OrderedCollections
import Spezi
import SpeziBluetooth
import SwiftUI

// TODO: Start SpeziDevices generalization
// TODO: Finish SpeziBluetooth refactoring and cleanup "persistent devices"
// TODO: dark mode device images
// TODO: ask for more Omron infos? secret sauce?


@Observable
class DeviceManager: Module, EnvironmentAccessible {
    /// Determines if the device discovery sheet should be presented.
    @MainActor var presentingDevicePairing = false
    @MainActor private(set) var discoveredDevices: OrderedDictionary<UUID, any PairableDevice> = [:]
    @MainActor @AppStorage("pairedDevices") @ObservationIgnored private var _pairedDevices: [PairedDeviceInfo] = []

    @MainActor private(set) var peripherals: [UUID: any PairableDevice] = [:]

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

    @Application(\.logger) @ObservationIgnored private var logger
    @Dependency @ObservationIgnored private var bluetooth: Bluetooth?

    init() {}

    func configure() {
        guard let bluetooth else {
            self.logger.warning("DeviceManager initialized without Bluetooth dependency!")
            return // useful for e.g. previews
        }

        // we just reuse the configured Bluetooth devices
        let configuredDevices = bluetooth.configuredPairableDevices

        // TODO: bit weird API wise!
        // We need to detach to not copy task local values
        Task.detached { @MainActor in
            // TODO: we need to redo this once bluetooth powers on?
            for deviceInfo in self.pairedDevices {
                guard self.peripherals[deviceInfo.id] == nil else {
                    continue
                }

                guard let deviceType = configuredDevices[deviceInfo.deviceType] else {
                    self.logger.error("Unsupported device type \"\(deviceInfo.deviceType)\" for paired device \(deviceInfo.name).")
                    continue
                }

                let device = await deviceType.retrievePeripheral(from: bluetooth, with: deviceInfo.id)

                guard let device else {
                    // TODO: once spezi bluetooth works (waiting for connected), this is an indication that the device was unpaired????
                    self.logger.warning("Device \(deviceInfo.id) \(deviceInfo.name) could not be retrieved!")
                    continue
                }

                assert(self.peripherals[device.id] == nil, "Cannot overwrite peripheral. Device \(deviceInfo) was paired twice.")
                self.peripherals[device.id] = device
                // TODO: we must store them (remove once we forget about them)?
                // TODO: we can instantly store newly paired devices!
                await device.connect() // TODO: might want to cancel that?

                // TODO: call connect after device disconnects?
            }
        }
    }

    @MainActor
    func isConnected(device: UUID) -> Bool {
        peripherals[device]?.state == .connected
    }

    @MainActor
    func isPaired<Device: PairableDevice>(_ device: Device) -> Bool {
        pairedDevices.contains { $0.id == device.id } // TODO: more efficient lookup!
    }

    @MainActor
    func handleDeviceStateUpdated<Device: PairableDevice>(_ device: Device, _ state: PeripheralState) {
        guard case .disconnected = state else {
            return
        }

        guard let deviceInfoIndex = pairedDevices.firstIndex(where: { $0.id == device.id }) else {
            return // not paired
        }

        // TODO: only update if previous state was connected (might have been just connecting!)
        pairedDevices[deviceInfoIndex].lastSeen = .now

        Task {
            // TODO: log?
            await device.connect() // TODO: handle something about that?, reuse with configure method?
        }
    }

    @MainActor
    func nearbyPairableDevice<Device: PairableDevice>(_ device: Device) {
        guard discoveredDevices[device.id] == nil else {
            return
        }

        guard !isPaired(device) else {
            return
        }

        self.logger.info("Detected nearby \(Device.self) accessory.")
        // TODO: previously we logged the manufacturer data!

        discoveredDevices[device.id] = device
        presentingDevicePairing = true
    }


    @MainActor
    func registerPairedDevice<Device: PairableDevice>(_ device: Device) async {
        var batteryLevel: UInt8?
        if let batteryDevice = device as? any BatteryPoweredDevice {
            batteryLevel = batteryDevice.battery.batteryLevel
        }

        if device.deviceInformation.modelNumber == nil && device.deviceInformation.$modelNumber.isPresent {
            // make sure it isn't just a race condition that we haven't received a value yet
            let readModel = try? await device.deviceInformation.$modelNumber.read()
            self.logger.info("ModelNumber was not present on device \(device.label), was read as \"\(readModel)\".")
        }

        // TODO: let omronManufacturerData = device.manufacturerData?.users.first?.sequenceNumber (which user to choose from?)
        let deviceInfo = PairedDeviceInfo(
            id: device.id,
            deviceType: Device.deviceTypeIdentifier,
            name: device.label,
            model: device.deviceInformation.modelNumber,
            icon: device.icon,
            batteryPercentage: batteryLevel
        )

        pairedDevices.append(deviceInfo)
        discoveredDevices[device.id] = nil


        assert(peripherals[device.id] == nil, "Cannot overwrite peripheral. Device \(deviceInfo) was paired twice.")
        peripherals[device.id] = device
    }

    @MainActor
    func handleDiscardedDevice<Device: OmronHealthDevice>(_ device: Device) {
        // device discovery was cleared by SpeziBluetooth
        self.logger.debug("\(Device.self) \(device.label) was discarded from discovered devices.") // TODO: devices do not disappear currently???
        discoveredDevices[device.id] = nil
    }

    @MainActor
    func forgetDevice(id: UUID) {
        pairedDevices.removeAll { info in
            info.id == id
        }
        
        let device = peripherals.removeValue(forKey: id)
        if let device {
            Task {
                await device.disconnect()
            }
        }
        // TODO: make sure to remove them from discoveredDevices?
    }

    @MainActor
    func updateBattery<Device: OmronHealthDevice>(for device: Device, percentage: UInt8) {
        guard let index = pairedDevices.firstIndex(where: { $0.id == device.id }) else {
            return
        }
        pairedDevices[index].lastBatteryPercentage = percentage
    }
}


extension Bluetooth {
    fileprivate nonisolated var configuredPairableDevices: [String: any PairableDevice.Type] {
        configuration.reduce(into: [:]) { partialResult, descriptor in
            guard let pairableDevice = descriptor.deviceType as? any PairableDevice.Type else {
                return
            }
            partialResult[pairableDevice.deviceTypeIdentifier] = pairableDevice
        }
    }
}


extension PairableDevice {
    fileprivate static func retrievePeripheral(from bluetooth: Bluetooth, with id: UUID) async -> Self? {
        await bluetooth.retrievePeripheral(for: id, as: Self.self)
    }
}
