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


protocol BatteryPoweredDevice: BluetoothDevice {
    var battery: BatteryService { get }
}


// TODO: not necessarily a HealthDevice?
protocol HealthDevice: BluetoothDevice, GenericBluetoothPeripheral {
    var id: UUID { get }
    var name: String? { get }
    var advertisementData: AdvertisementData { get }
    var discarded: Bool { get }

    var deviceInformation: DeviceInformationService { get }

    var icon: ImageReference? { get }
}


extension HealthDevice {
    var label: String {
        name ?? "Health Device"
    }
}
