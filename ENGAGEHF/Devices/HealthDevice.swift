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


protocol HealthDevice: GenericBluetoothPeripheral {
    var id: UUID { get }
    var name: String? { get }
    var advertisementData: AdvertisementData { get }

    var deviceInformation: DeviceInformationService { get }
}


extension HealthDevice {
    var manufacturerData: OmronManufacturerData? { // TODO: we could add syntactic sugar to spezi with storage for decoded value?
        guard let manufacturerData = advertisementData.manufacturerData else {
            return nil
        }
        return OmronManufacturerData(data: manufacturerData)
    }

    var label: String {
        name ?? "Health Device"
    }

    var model: OmronModel {
        OmronModel(deviceInformation.modelNumber ?? "Generic Health Device") // TODO: fallback picture for that?
    }
}
