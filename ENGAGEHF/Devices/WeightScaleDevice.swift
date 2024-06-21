//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import BluetoothServices
import CoreBluetooth
import Foundation
import OSLog
@_spi(TestingSupport) import SpeziBluetooth


/// A bluetooth peripheral representing a Weight Scale
///
/// On new measurement, loads the measurement into the MeasurementManager
/// as a HealthKit HKQuantitySample.
class WeightScaleDevice: BluetoothDevice, Identifiable, OmronHealthDevice {
    private static let logger = Logger(subsystem: "ENGAGEHF", category: "WeightScale")

    @DeviceState(\.id) var id: UUID
    @DeviceState(\.name)var name: String?
    @DeviceState(\.state) var state: PeripheralState
    @DeviceState(\.advertisementData) var advertisementData: AdvertisementData
    @DeviceState(\.discarded) var discarded

    @Service var deviceInformation = DeviceInformationService()

    @Service var time = CurrentTimeService()
    @Service var weightScale = WeightScaleService()
    
    @DeviceAction(\.connect) var connect
    @DeviceAction(\.disconnect) var disconnect

    @Dependency private var measurementManager: MeasurementManager?
    @Dependency private var deviceManager: DeviceManager?

    @MainActor var _pairingContinuation: CheckedContinuation<Void, any Error>? // swiftlint:disable:this identifier_name

    var icon: ImageReference? {
        .asset("Omron-SC-150")
    }

    required init() {
        $state
            .onChange(perform: handleStateChange(_:))
        $advertisementData.onChange(initial: true, perform: handleAdvertisement(_:))
        $discarded.onChange { @MainActor discarded in
            if discarded {
                self.deviceManager?.handleDiscardedDevice(self)
            }
        }

        weightScale.$weightMeasurement
            .onChange(perform: processMeasurement(_:))
        time.$currentTime
            .onChange(perform: handleCurrentTimeChange(_:))
    }

    private func handleAdvertisement(_ data: AdvertisementData) {
        // TODO: are initial states called without dependencies injected?

        guard let manufacturerData else {
            // e.g., happens when device is connected without prior advertising
            return
        }


        if case .pairingMode = manufacturerData.pairingMode {
            Task { @MainActor in
                deviceManager?.nearbyPairableDevice(self)
            }
        }
    }

    private func handleStateChange(_ state: PeripheralState) async {
        if case .disconnected = state {
            await handleDeviceDisconnected()
        }

        await deviceManager?.handleDeviceStateUpdated(self, state)

        if case .connected = state {
            time.synchronizeDeviceTime()
        }
    }

    private func processMeasurement(_ measurement: WeightMeasurement) {
        guard let measurementManager else {
            preconditionFailure("Measurement Manager was not configured")
        }
        Self.logger.debug("Received new weight measurement: \(String(describing: measurement))")
        measurementManager.handleNewMeasurement(.weight(measurement, weightScale.features ?? []), from: self)
    }

    @MainActor
    private func handleCurrentTimeChange(_ time: CurrentTime) {
        // TODO: paired is successful even before Pair button is pressed?
        Self.logger.debug("Updated device time for \(self.label) is \(String(describing: time))")
        handleDeviceInteraction()
    }
}


extension WeightScaleDevice {
    static func createMockDevice(
        weight: UInt16 = 8400,
        resolution: WeightScaleFeature.WeightResolution = .resolution5g,
        state: PeripheralState = .connected,
        manufacturerData: OmronManufacturerData = OmronManufacturerData(pairingMode: .pairingMode, users: [
            .init(id: 1, sequenceNumber: 2, recordsNumber: 1)
        ])
    ) -> WeightScaleDevice {
        let device = WeightScaleDevice()

        device.deviceInformation.$manufacturerName.inject("Mock Weight Scale")
        device.deviceInformation.$modelNumber.inject(OmronModel.sc150.rawValue)
        device.deviceInformation.$hardwareRevision.inject("2")
        device.deviceInformation.$firmwareRevision.inject("1.0")

        // mocks the values as reported by the real device
        let features = WeightScaleFeature(
            weightResolution: resolution,
            heightResolution: .unspecified,
            options: .timeStampSupported
        )

        let measurement = WeightMeasurement(
            weight: weight,
            unit: .si
        )
        
        device.weightScale.$features.inject(features)
        device.weightScale.$weightMeasurement.inject(measurement)

        device.$id.inject(UUID())
        device.$name.inject("Mock Health Scale")
        device.$state.inject(state)

        let advertisementData = AdvertisementData([
            CBAdvertisementDataManufacturerDataKey: manufacturerData.encode()
        ])
        device.$advertisementData.inject(advertisementData)

        device.$connect.inject { @MainActor [weak device] in
            device?.$state.inject(.connecting)
            await device?.handleStateChange(.connecting)

            try? await Task.sleep(for: .seconds(1))

            device?.$state.inject(.connected)
            await device?.handleStateChange(.connected)
        }

        device.$disconnect.inject { @MainActor [weak device] in
            device?.$state.inject(.disconnected)
            await device?.handleStateChange(.disconnected)
        }

        return device
    }
}
