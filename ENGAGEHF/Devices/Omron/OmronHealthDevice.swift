//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation
import SpeziBluetooth
import SwiftUI


protocol OmronHealthDevice: HealthDevice {
    /// Storage for pairing continuation.
    @MainActor var _pairingContinuation: CheckedContinuation<Void, Error>? { get set } // swiftlint:disable:this identifier_name
    // TODO: do not synchronize via MainActor??
    // TODO: use SPI instead of underscore when moving to SpeziDevices?

    var connect: BluetoothConnectAction { get } // TODO: on which level to enforce that?

    /// Pair Omron Health Device.
    ///
    /// This method pairs a currently advertising Omron Health Device.
    /// - Note: Make sure that the device is in pairing mode (holding down the Bluetooth button for 3 seconds) and disconnected.
    ///
    /// This method is implemented by default. In order to support the default implementation, you MUST call `handleDeviceInteraction()`
    /// on notifications or indications received from the device. This indicates that pairing was successful.
    @MainActor // TODO: actor isolation?
    func pair() async throws // TODO: docs: onChange disconnected!
}


extension OmronHealthDevice {
    var model: OmronModel {
        OmronModel(deviceInformation.modelNumber ?? "Generic Health Device") // TODO: fallback picture for that? => "sensor.fill"?
    }

    var icon: Image {
        guard let model = deviceInformation.modelNumber else {
            return Image(systemName: "sensor")
                .symbolRenderingMode(.hierarchical)
        }
        return Image("Omron-\(model)")
    }

    // TODO: we could add syntactic sugar to spezi with storage for decoded value? (what???)
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

        guard case .disconnected = state else {
            throw DevicePairingError.invalidState
        }

        await connect()

        async let _ = withTimeout(of: .seconds(30)) { @MainActor in
            if let pairingContinuation = _pairingContinuation {
                pairingContinuation.resume(throwing: TimeoutError())
                self._pairingContinuation = nil
            }
        }

        // TODO: cancellation handler?
        // TODO: return error if the device disconnects while pairing?
        try await withCheckedThrowingContinuation { continuation in
            self._pairingContinuation = continuation
        }

        print("\(id) is now considered paired!") // TODO: logger!
    }

    @MainActor
    func handleDeviceInteraction() {
        // any kind of messages received from the the device is interpreted as successful pairing.
        if let pairingContinuation = _pairingContinuation {
            pairingContinuation.resume()
            self._pairingContinuation = nil
        }
    }
}
