//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziBluetooth
import SpeziFoundation
import SwiftUI


protocol OmronHealthDevice: HealthDevice {
    /// Storage for pairing continuation.
    @MainActor var _pairingContinuation: CheckedContinuation<Void, Error>? { get set } // swiftlint:disable:this identifier_name
    // TODO: do not synchronize via MainActor??
    // TODO: use SPI instead of underscore when moving to SpeziDevices? => avoid swiftlint warning for implementors

    var connect: BluetoothConnectAction { get } // TODO: on which level to enforce that?
    var disconnect: BluetoothDisconnectAction { get }

    /// Pair Omron Health Device.
    ///
    /// This method pairs a currently advertising Omron Health Device.
    /// - Note: Make sure that the device is in pairing mode (holding down the Bluetooth button for 3 seconds) and disconnected.
    ///
    /// This method is implemented by default. In order to support the default implementation, you MUST call `handleDeviceInteraction()`
    /// on notifications or indications received from the device. This indicates that pairing was successful.
    /// Further, your implementation MUST call `handleDeviceDisconnected()` if the device disconnects to handle pairing issues.
    @MainActor // TODO: actor isolation?
    func pair() async throws
}


extension OmronHealthDevice {
    var model: OmronModel {
        OmronModel(deviceInformation.modelNumber ?? "Generic Health Device")
    }

    var manufacturerData: OmronManufacturerData? {
        guard let manufacturerData = advertisementData.manufacturerData else {
            return nil
        }
        return OmronManufacturerData(data: manufacturerData)
    }
}


extension OmronHealthDevice {
    @MainActor
    func pair() async throws {
        guard _pairingContinuation == nil else {
            throw DevicePairingError.busy
        }

        guard case .pairingMode = manufacturerData?.pairingMode else {
            throw DevicePairingError.notInPairingMode
        }

        // TODO: can we check if the device is still considered discovered???
        guard case .disconnected = state else {
            throw DevicePairingError.invalidState
        }

        await connect()

        async let _ = withTimeout(of: .seconds(15)) { @MainActor in
            resumePairingContinuation(with: .failure(TimeoutError()))
        }

        try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                self._pairingContinuation = continuation
            }
        } onCancel: {
            Task { @MainActor in
                resumePairingContinuation(with: .failure(CancellationError()))
                await disconnect()
            }
        }


        print("\(id) is now considered paired!") // TODO: logger!
    }

    @MainActor
    func handleDeviceInteraction() {
        // any kind of messages received from the the device is interpreted as successful pairing.
        resumePairingContinuation(with: .success(()))
    }

    @MainActor
    func handleDeviceDisconnected() {
        resumePairingContinuation(with: .failure(DevicePairingError.deviceDisconnected))
    }

    @MainActor
    private func resumePairingContinuation(with result: Result<Void, Error>) {
        if let pairingContinuation = _pairingContinuation {
            pairingContinuation.resume(with: result)
            self._pairingContinuation = nil
        }
    }
}
