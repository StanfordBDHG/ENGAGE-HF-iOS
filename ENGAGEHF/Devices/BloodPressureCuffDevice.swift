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


class BloodPressureCuffDevice: BluetoothDevice, Identifiable, HealthDevice {
    private static let logger = Logger(subsystem: "ENGAGEHF", category: "BloodPressureCuffDevice")

    @DeviceState(\.id) var id: UUID
    @DeviceState(\.name) var name: String?
    @DeviceState(\.state) var state: PeripheralState

    @Service var deviceInformation = DeviceInformationService()

    @Service var time = CurrentTimeService()
    @Service var bloodPressure = BloodPressureService()

    @DeviceAction(\.connect) var connect
    @DeviceAction(\.disconnect) var disconnect

    // TODO: user data service?
    // TODO: record access service!
    
    @Dependency private var measurementManager: MeasurementManager?

    required init() {
        $state
            .onChange(perform: handleStateChange)
        bloodPressure.$bloodPressureMeasurement
            .onChange(initial: true, perform: processMeasurement)
    }

    private func handleStateChange(_ state: PeripheralState) {
        guard case .connected = state else {
            return
        }

        time.ensureUpdatedTime()
    }

    private func processMeasurement(_ measurement: BloodPressureMeasurement) {
        guard let measurementManager else {
            preconditionFailure("Measurement Manager was not configured")
        }

        print("Received new measurement: \(measurement)") // TOOD: update log
        measurementManager.handleNewMeasurement(.bloodPressure(measurement, bloodPressure.features ?? []), from: self)
    }
}


extension BloodPressureCuffDevice {
    static func createMockDevice() -> BloodPressureCuffDevice {
        let device = BloodPressureCuffDevice()

        device.deviceInformation.$manufacturerName.inject("Mock Blood Pressure Cuff")
        device.deviceInformation.$modelNumber.inject("1")
        device.deviceInformation.$hardwareRevision.inject("2")
        device.deviceInformation.$firmwareRevision.inject("1.0")

        let features: BloodPressureFeature = [
            .bodyMovementDetectionSupported,
            .irregularPulseDetectionSupported
        ]

        let measurement = BloodPressureMeasurement(
            systolic: 103,
            diastolic: 64,
            meanArterialPressure: 77,
            unit: .mmHg,
            timeStamp: DateTime(year: 2024, month: .june, day: 5, hours: 12, minutes: 33, seconds: 11),
            pulseRate: 62,
            userId: 1,
            measurementStatus: []
        )

        device.bloodPressure.$features.inject(features)
        device.bloodPressure.$bloodPressureMeasurement.inject(measurement)

        device.$id.inject(UUID())
        device.$name.inject("Mock Blood Pressure Cuff")
        device.$state.inject(.connected)

        device.$connect.inject { @MainActor [weak device] in
            device?.$state.inject(.connecting)
            // TODO: onchange!

            try? await Task.sleep(for: .seconds(1))

            device?.$state.inject(.connected)
        }

        device.$disconnect.inject { @MainActor [weak device] in
            device?.$state.inject(.disconnected)
        }

        return device
    }
}
