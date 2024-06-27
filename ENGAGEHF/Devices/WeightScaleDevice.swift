//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import CoreBluetooth
import Foundation
import OSLog
@_spi(TestingSupport) import SpeziBluetooth
import SpeziBluetoothServices
import SpeziDevices
import SpeziOmron


class WeightScaleDevice: BluetoothDevice, Identifiable, OmronHealthDevice {
    private static let logger = Logger(subsystem: "ENGAGEHF", category: "WeightScale")

    @DeviceState(\.id) var id: UUID
    @DeviceState(\.name)var name: String?
    @DeviceState(\.state) var state: PeripheralState
    @DeviceState(\.advertisementData) var advertisementData: AdvertisementData
    @DeviceState(\.nearby) var nearby

    @Service var deviceInformation = DeviceInformationService()

    @Service var time = CurrentTimeService()
    @Service var weightScale = WeightScaleService()
    
    @DeviceAction(\.connect) var connect
    @DeviceAction(\.disconnect) var disconnect

    @Dependency private var measurements: HealthMeasurements?
    @Dependency private var pairedDevices: PairedDevices?

    private var dateOfConnection: Date?

    var icon: ImageReference? {
        .asset("Omron-SC-150")
    }

    required init() {}

    func configure() {
        $state.onChange { [weak self] value in
            await self?.handleStateChange(value)
        }

        time.$currentTime.onChange { [weak self] value in
            await self?.handleCurrentTimeChange(value)
        }

        if let pairedDevices {
            pairedDevices.configure(device: self, accessing: $state, $advertisementData, $nearby)
        }
        if let measurements {
            measurements.configureReceivingMeasurements(for: self, on: weightScale)
        }
    }

    private func handleStateChange(_ state: PeripheralState) async {
        switch state {
        case .connected:
            switch manufacturerData?.pairingMode {
            case .pairingMode:
                print("Device connection is NOW!")
                dateOfConnection = .now
            case .transferMode:
                time.synchronizeDeviceTime()
            case nil:
                break
            }
        default:
            break
        }
    }

    @MainActor
    private func handleCurrentTimeChange(_ time: CurrentTime) {
        if case .pairingMode = manufacturerData?.pairingMode,
           let dateOfConnection,
           abs(Date.now.timeIntervalSince1970 - dateOfConnection.timeIntervalSince1970) < 1 {
            // if its pairing mode, and we just connected, we ignore the first current time notification as its triggered
            // because of the notification registration.
            return
        }

        Self.logger.debug("Received updated device time for \(self.label): \(String(describing: time))")
        let paired = pairedDevices?.signalDevicePaired(self) == true
        if paired {
            dateOfConnection = nil
            self.time.synchronizeDeviceTime()
        }
    }
}


#if DEBUG || TEST
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
#endif
