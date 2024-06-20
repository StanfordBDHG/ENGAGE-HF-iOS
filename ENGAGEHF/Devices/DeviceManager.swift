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


@Observable
class DeviceManager: Module, EnvironmentAccessible {
    /// Determines if the device discovery sheet should be presented.
    @MainActor var presentingDevicePairing = false
    @MainActor private(set) var discoveredDevices: OrderedDictionary<UUID, any OmronHealthDevice> = [:]
    @MainActor @AppStorage("pairedDevices") @ObservationIgnored private var _pairedDevices: [PairedDeviceInfo] = []

    @MainActor private(set) var peripherals: [UUID: any OmronHealthDevice] = [:]

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
            return // useful for e.g. previews
            // TODO: preconditionFailure("Tried to configure DeviceManager without having Bluetooth module configured!")
        }

        // TODO: bit weird API wise!
        // We need to detach to not copy task local values
        Task.detached { @MainActor in
            // TODO: we need to redo this once bluetooth powers on?
            for deviceInfo in self.pairedDevices {
                let device: (any OmronHealthDevice)?
                switch deviceInfo.model {
                case OmronModel.bp5250.rawValue:
                    device = await bluetooth.retrievePeripheral(for: deviceInfo.id, as: BloodPressureCuffDevice.self)
                case OmronModel.sc150.rawValue:
                    device = await bluetooth.retrievePeripheral(for: deviceInfo.id, as: WeightScaleDevice.self)
                default:
                    self.logger.warning("Unsupported model: \(deviceInfo.model)") // TODO: what to do?
                    continue
                }
                // TODO: how to determine the device type?
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
    func isPaired<Device: OmronHealthDevice>(_ device: Device) -> Bool {
        pairedDevices.contains { $0.id == device.id } // TODO: more efficient lookup!
    }

    @MainActor
    func handleDeviceStateUpdated<Device: OmronHealthDevice>(_ device: Device, _ state: PeripheralState) {
        guard case .disconnected = state else {
            return
        }

        guard let deviceInfoIndex = pairedDevices.firstIndex(where: { $0.id == device.id }) else {
            return // not paired
        }

        pairedDevices[deviceInfoIndex].lastSeen = .now

        Task {
            // TODO: log?
            await device.connect() // TODO: handle something about that?, reuse with configure method?
        }
    }

    @MainActor
    func nearbyPairableDevice<Device: OmronHealthDevice>(_ device: Device) {
        guard discoveredDevices[device.id] == nil else {
            return
        }

        guard !isPaired(device) else {
            return
        }

        self.logger.info("Detected nearby \(Device.self) with manufacturer data \(String(describing: device.manufacturerData))")

        discoveredDevices[device.id] = device
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
        // TODO: also make sure they disconnect?
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
