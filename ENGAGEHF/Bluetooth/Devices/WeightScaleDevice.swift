//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import BluetoothServices
import Foundation
@_spi(TestingSupport) import SpeziBluetooth


//
// A bluetooth peripheral representing a Weight Scale
//
// On new measurement, loads the measurement into the MeasurementManager
// as a HealthKit HKQuantitySample
//
class WeightScaleDevice: BluetoothDevice, Identifiable {
    @DeviceState(\.id) var id: UUID
    @DeviceState(\.name)var name: String?
    @DeviceState(\.state) var state: PeripheralState
    
    @Service var deviceInformation = DeviceInformationService()
    @Service var service = WeightScaleService()
    
    @DeviceAction(\.connect) var connect
    @DeviceAction(\.disconnect) var disconnect
    
    
    required init() {
        service.$weightMeasurement.onChange(perform: processMeasurement)
    }
    
    private func processMeasurement(_ measurement: WeightMeasurement) {
        if !service.$weightMeasurement.isPresent {
            return
        }

        MeasurementManager.manager.handleMeasurement(measurement, from: self)
    }
}


extension WeightMeasurement.Unit {
    var massUnit: String {
        switch self {
        case .si:
            return "kg"
        case .imperial:
            return "lb"
        }
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
        
        device.service.$features.inject(features)
        device.service.$weightMeasurement.inject(measurement)

        device.$id.inject(UUID())
        device.$name.inject("Mock Health Scale")
        device.$state.inject(.connected)

        device.$connect.inject { @MainActor [weak device] in
            device?.$state.inject(.connecting)

            try? await Task.sleep(for: .seconds(1))

            device?.$state.inject(.connected)
        }

        device.$disconnect.inject { @MainActor [weak device] in
            device?.$state.inject(.disconnected)
        }

        return device
    }
}
