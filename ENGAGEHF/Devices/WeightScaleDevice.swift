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


/// A bluetooth peripheral representing a Weight Scale
///
/// On new measurement, loads the measurement into the MeasurementManager
/// as a HealthKit HKQuantitySample.
class WeightScaleDevice: BluetoothDevice, Identifiable, HealthDevice {
    private static let logger = Logger(subsystem: "ENGAGEHF", category: "WeightScale")

    @DeviceState(\.id) var id: UUID
    @DeviceState(\.name)var name: String?
    @DeviceState(\.state) var state: PeripheralState
    
    @Service var deviceInformation = DeviceInformationService()

    @Service var time = CurrentTimeService()
    @Service var weightScale = WeightScaleService()
    
    @DeviceAction(\.connect) var connect
    @DeviceAction(\.disconnect) var disconnect


    @Dependency private var measurementManager: MeasurementManager?

    
    required init() {
        $state
            .onChange(perform: handleStateChange)
        weightScale.$weightMeasurement
            .onChange(perform: processMeasurement)
    }

    private func handleStateChange(_ state: PeripheralState) { // TODO: call from the mock device!
        guard case .connected = state else {
            return
        }

        time.ensureUpdatedTime()
    }

    private func processMeasurement(_ measurement: WeightMeasurement) {
        guard let measurementManager else {
            preconditionFailure("Measurement Manager was not configured")
        }
        // TODO: add custom string convertible conformance to all characteristics!
        Self.logger.debug("Received new weight measurement: \(String(describing: measurement))")
        measurementManager.handleNewMeasurement(.weight(measurement, weightScale.features ?? []), from: self)
    }
}


extension WeightScaleDevice {
    static func createMockDevice(weight: UInt16 = 8400, resolution: WeightScaleFeature.WeightResolution = .resolution5g) -> WeightScaleDevice {
        let device = WeightScaleDevice()

        device.deviceInformation.$manufacturerName.inject("Mock Weight Scale")
        device.deviceInformation.$modelNumber.inject("1")
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
