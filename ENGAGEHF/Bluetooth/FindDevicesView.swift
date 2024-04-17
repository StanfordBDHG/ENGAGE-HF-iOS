//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziBluetooth
import SwiftUI


struct FindDevicesView: View {
    @Environment(Bluetooth.self) var bluetooth
    @Environment(WeightScaleDevice.self) var weightScale: WeightScaleDevice?
    
    var body: some View {
        List {
            if let weightScale {
                Section {
                    Text("Device")
                    Spacer()
                    Text("\(weightScale.state.description)")
                }
            }
            
            Section {
                ForEach(bluetooth.nearbyDevices(for: WeightScaleDevice.self), id: \.id) { device in
                    Text("\(device.name ?? "unknown")")
                }
            } header: {
                HStack {
                    Text("Devices")
                        .padding(.trailing, 10)
                    if bluetooth.isScanning {
                        ProgressView()
                    }
                }
            }
        }
            .scanNearbyDevices(with: bluetooth, autoConnect: true)
    }
}


#Preview {
    FindDevicesView()
}
