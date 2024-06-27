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
import SpeziNumerics
import SpeziOmron


class BloodPressureCuffDevice: BluetoothDevice, Identifiable, OmronHealthDevice, BatteryPoweredDevice {
    private static let logger = Logger(subsystem: "ENGAGEHF", category: "BloodPressureCuffDevice")

    @DeviceState(\.id) var id: UUID
    @DeviceState(\.name) var name: String?
    @DeviceState(\.state) var state: PeripheralState
    @DeviceState(\.advertisementData) var advertisementData: AdvertisementData
    @DeviceState(\.nearby) var nearby

    @Service var deviceInformation = DeviceInformationService()

    @Service var time = CurrentTimeService()
    @Service var battery = BatteryService()
    @Service var bloodPressure = BloodPressureService()

    @DeviceAction(\.connect) var connect
    @DeviceAction(\.disconnect) var disconnect
    
    @Dependency private var measurements: HealthMeasurements?
    @Dependency private var pairedDevices: PairedDevices?

    var icon: ImageReference? {
        .asset("Omron-BP5250")
    }

    required init() {}

    func configure() {
        $state.onChange { [weak self] value in
            await self?.handleStateChange(value)
        }

        battery.$batteryLevel.onChange { [weak self] value in
            await self?.handleBatteryChange(value)
        }
        time.$currentTime.onChange { [weak self] value in
            await self?.handleCurrentTimeChange(value)
        }

        if let pairedDevices {
            pairedDevices.configure(device: self, accessing: $state, $advertisementData, $nearby)
        }
        if let measurements {
            measurements.configureReceivingMeasurements(for: self, on: bloodPressure)
        }
    }

    private func handleStateChange(_ state: PeripheralState) async {
        if case .connected = state { // TODO: only after pairing completed?
            time.synchronizeDeviceTime()
        }
    }

    @MainActor
    private func handleBatteryChange(_ level: UInt8) {
        pairedDevices?.signalDevicePaired(self)
    }

    @MainActor
    private func handleCurrentTimeChange(_ time: CurrentTime) {
        Self.logger.debug("Updated device time for \(self.label) is \(String(describing: time))")
        pairedDevices?.signalDevicePaired(self)
    }
}


#if DEBUG || TEST
extension BloodPressureCuffDevice {
    static func createMockDevice(
        systolic: MedFloat16 = 103,
        diastolic: MedFloat16 = 64,
        pulseRate: MedFloat16 = 62,
        state: PeripheralState = .connected,
        manufacturerData: OmronManufacturerData = OmronManufacturerData(pairingMode: .pairingMode, users: [
            .init(id: 1, sequenceNumber: 2, recordsNumber: 1)
        ])
    ) -> BloodPressureCuffDevice {
        let device = BloodPressureCuffDevice()

        device.deviceInformation.$manufacturerName.inject("Mock Blood Pressure Cuff")
        device.deviceInformation.$modelNumber.inject(OmronModel.bp5250.rawValue)
        device.deviceInformation.$hardwareRevision.inject("2")
        device.deviceInformation.$firmwareRevision.inject("1.0")

        let features: BloodPressureFeature = [
            .bodyMovementDetectionSupported,
            .irregularPulseDetectionSupported
        ]

        let measurement = BloodPressureMeasurement(
            systolic: systolic,
            diastolic: diastolic,
            meanArterialPressure: 77,
            unit: .mmHg,
            timeStamp: DateTime(year: 2024, month: .june, day: 5, hours: 12, minutes: 33, seconds: 11),
            pulseRate: pulseRate,
            userId: 1,
            measurementStatus: []
        )

        device.bloodPressure.$features.inject(features)
        device.bloodPressure.$bloodPressureMeasurement.inject(measurement)

        device.$id.inject(UUID())
        device.$name.inject("Mock Blood Pressure Cuff")
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
