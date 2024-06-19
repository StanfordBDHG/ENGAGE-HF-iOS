//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import BluetoothServices
import Foundation
import OSLog
@_spi(TestingSupport) import SpeziBluetooth
import SpeziFoundation
import SpeziNumerics
import SpeziOmron


class BloodPressureCuffDevice: BluetoothDevice, Identifiable, OmronHealthDevice {
    private static let logger = Logger(subsystem: "ENGAGEHF", category: "BloodPressureCuffDevice")

    @DeviceState(\.id) var id: UUID
    @DeviceState(\.name) var name: String?
    @DeviceState(\.state) var state: PeripheralState
    @DeviceState(\.advertisementData) var advertisementData: AdvertisementData
    @DeviceState(\.discarded) var discarded

    @Service var deviceInformation = DeviceInformationService()

    @Service var time = CurrentTimeService()
    @Service var battery = BatteryService()
    @Service var bloodPressure = BloodPressureService()
    @Service var omronOptions = OmronOptionService()

    @DeviceAction(\.connect) var connect
    @DeviceAction(\.disconnect) var disconnect
    
    @Dependency private var measurementManager: MeasurementManager?
    @Dependency private var deviceManager: DeviceManager?

    @MainActor var _pairingContinuation: CheckedContinuation<Void, Error>? // swiftlint:disable:this identifier_name

    var icon: ImageReference? {
        .asset("Omron-BP5250")
    }

    required init() {
        $state
            .onChange(perform: handleStateChange(_:))
        bloodPressure.$bloodPressureMeasurement
            .onChange(perform: processMeasurement(_:))
        battery.$batteryLevel
            .onChange(perform: handleBatteryChange(_:))
        time.$currentTime
            .onChange(perform: handleCurrentTimeChange(_:))
        $discarded.onChange { @MainActor discarded in
            if discarded {
                self.deviceManager?.handleDiscardedDevice(self)
            }
        }
    }

    func configure() {
        guard let manufacturerData else {
            Self.logger.debug("Ignoring unknown blood pressure cuff device \(self.label).")
            return
        }


        Self.logger.info("Detected nearby blood pressure cuff with manufacturer data \(String(describing: manufacturerData))")
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

        guard case .connected = state else {
            return
        }

        time.synchronizeDeviceTime()


        return;
        Task {
            try? await Task.sleep(for: .seconds(1)) // TODO: isNotifying is outdated at this point!
            print("Requesting latest sequence number!")
            do {
                let recordsCount = try await omronOptions.reportNumberOfStoredRecords(.allRecords)
                print("Records count: \(recordsCount)")
                let sequenceNumber = try await omronOptions.reportSequenceNumberOfLatestRecords()

                print("latest sequence number: \(sequenceNumber)")
            } catch {
                print("Error occurred: \(error)")
            }

            do {
                try await omronOptions.reportStoredRecords(.lastRecord)
            } catch {
                print("Failed to report stored records: \(error)")
            }
        }
    }

    private func processMeasurement(_ measurement: BloodPressureMeasurement) {
        guard let measurementManager else {
            preconditionFailure("Measurement Manager was not configured")
        }

        Self.logger.debug("Received new blood pressure measurement: \(String(describing: measurement))")
        measurementManager.handleNewMeasurement(.bloodPressure(measurement, bloodPressure.features ?? []), from: self)
    }

    @MainActor
    private func handleBatteryChange(_ level: UInt8) {
        Self.logger.debug("Updated battery level for \(self.label) is \(level)")
        handleDeviceInteraction()
        deviceManager?.updateBattery(for: self, percentage: level)
    }

    @MainActor
    private func handleCurrentTimeChange(_ time: CurrentTime) {
        Self.logger.debug("Updated device time for \(self.label) is \(String(describing: time))")
        handleDeviceInteraction()
    }
}


extension BloodPressureCuffDevice {
    static func createMockDevice(
        systolic: MedFloat16 = 103,
        diastolic: MedFloat16 = 64,
        pulseRate: MedFloat16 = 62,
        state: PeripheralState = .connected
    ) -> BloodPressureCuffDevice {
        // TODO: inject manufacturer data?
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
