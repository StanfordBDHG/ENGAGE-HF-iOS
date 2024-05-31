//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import BluetoothServices
import Foundation
import SpeziBluetooth


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
        
        MeasurementManager.manager.deviceInformation = deviceInformation
        MeasurementManager.manager.weightScaleParams = service.features
        MeasurementManager.manager.deviceName = name
        
        MeasurementManager.manager.loadMeasurement(measurement)
    }
}


// TODO: move somewhere!
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
