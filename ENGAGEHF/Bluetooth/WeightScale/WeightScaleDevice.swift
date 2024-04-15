//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import BluetoothServices
import class CoreBluetooth.CBUUID
import SpeziBluetooth


// The primary Weight Scale Service
// Note: Access properties: R: read, W: write, N: notify
class WeightScaleService: BluetoothService {
    static var id = CBUUID(string: "181D")
    
    // 2 characteristics as defined in the manual:
    
    // Characteristic 1: Weight Scale Feature, R
    @Characteristic(id: "2A9E")
    var weightScaleFeature: WeightScaleFeature?
    
    // Characteristic 2: Weight Measurement, N
    @Characteristic(id: "2A9D", notify: true)
    var weightMeasurement: WeightMeasurement?
    
    init() {}
}


class WeightScaleDevice: BluetoothDevice, Identifiable {
    
    @Service var deviceInformation = DeviceInformationService()
    @Service var service = WeightScaleService()
    
    required init() {}
}
