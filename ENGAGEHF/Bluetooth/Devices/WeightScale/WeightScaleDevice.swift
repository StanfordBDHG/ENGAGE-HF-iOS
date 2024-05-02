//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import BluetoothServices
import class CoreBluetooth.CBUUID
import FirebaseCore
import FirebaseFirestore
import Foundation
import SpeziBluetooth


// The primary Weight Scale Service
// Note: Access properties: R: read, W: write, N: notify
class WeightScaleService: BluetoothService {
    static var id = CBUUID(string: "181D")
    
    // 2 characteristics as defined in the manual:
    
    // Characteristic 1: Weight Scale Feature, R
    @Characteristic(id: "2A9E") var weightScaleFeature: WeightScaleFeature?
    
    // Characteristic 2: Weight Measurement, N
    @Characteristic(id: "2A9D", notify: true) var weightMeasurement: WeightMeasurement?
    
    init() {}
}


class WeightScaleDevice: BluetoothDevice, Identifiable {
    @DeviceState(\.id) var id: UUID
    @DeviceState(\.name)var name: String?
    @DeviceState(\.state) var state: PeripheralState
    
    @Service var deviceInformation = DeviceInformationService()
    @Service var service = WeightScaleService()
    
    @DeviceAction(\.connect) var connect
    @DeviceAction(\.disconnect) var disconnect
    
    
    required init() {
        $state.onChange(perform: handleConnect)
        service.$weightMeasurement.onChange(perform: processMeasurement)
    }
    
    
    private func handleConnect(_ state: PeripheralState) async {
        // For now, only handle connection and ignore other stages
//        if !(state == .connected) {
//            await connect()
//        }
//        
        // Read device information and weight feature
        do {
            if service.$weightScaleFeature.isPresent {
                try await service.$weightScaleFeature.read()
            }
            
            try await deviceInformation.retrieveDeviceInformation()
        } catch {
            print("\(error)")
        }
    }
    
    private func processMeasurement(_ measurement: WeightMeasurement) async {
        if !service.$weightMeasurement.isPresent {
            return
        }
        
        print("Saving the following measurement: \(Double(measurement.weight) / 100)")
        let firestore = Firestore.firestore()
        
        do {
            try await firestore.collection("measurements").document("test").setData(from: Double(measurement.weight) / 100)
            print("Successfully saved measurement to firestore")
        } catch {
            print("Failed to write measurment to firestore: \(error)")
        }
    }
    
    // Call when ready to disconnect
    private func finished() async {
        await disconnect()
    }
}
