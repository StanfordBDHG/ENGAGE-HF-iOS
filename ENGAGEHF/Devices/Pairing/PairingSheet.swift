//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziBluetooth
import SwiftUI


struct PairingSheet: View {
    @Environment(Bluetooth.self) private var bluetooth
    @Environment(DeviceManager.self) private var deviceManager

    @State private var path = NavigationPath()

    var body: some View {
        @Bindable var deviceManager = deviceManager

        NavigationStack(path: $path) {
            DevicesGrid(devices: $deviceManager.pairedDevices, navigation: $path, presentingDevicePairing: $deviceManager.presentingDevicePairing)
                .scanNearbyDevices(enabled: deviceManager.scanningNearbyDevices, with: bluetooth) // automatically search if no devices are paired
                .sheet(isPresented: $deviceManager.presentingDevicePairing) {
                    AccessorySetupSheet(deviceManager.discoveredDevices.values)
                }
                .toolbar {
                    // indicate that we are scanning in the background
                    if deviceManager.scanningNearbyDevices && !deviceManager.presentingDevicePairing {
                        ToolbarItem(placement: .cancellationAction) {
                            ProgressView()
                        }
                    }
                }
        }
    }
}


#if DEBUG
#Preview {
    PairingSheet()
        .previewWith {
            Bluetooth {}
            DeviceManager()
        }
}
#endif
