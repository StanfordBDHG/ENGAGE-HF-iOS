//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import BluetoothServices
import BluetoothViews
import Foundation
import SpeziBluetooth
import SwiftUI


protocol HealthDevice: AnyObject, GenericBluetoothPeripheral {
    var id: UUID { get }
    var name: String? { get }
    var advertisementData: AdvertisementData { get }
    
    var deviceInformation: DeviceInformationService { get }
    var battery: BatteryService { get } // TODO: this might be optional to implement

    var icon: ImageReference? { get }
}


extension HealthDevice {
    var label: String {
        name ?? "Health Device"
    }
}
