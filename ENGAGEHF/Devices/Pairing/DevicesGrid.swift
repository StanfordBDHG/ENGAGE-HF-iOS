//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct DevicesGrid: View {
    private let devices: [PairedDeviceInfo]


    @Binding private var presentingDevicePairing: Bool


    private var gridItems = [
        GridItem(.adaptive(minimum: 120, maximum: 800), spacing: 10),
        GridItem(.adaptive(minimum: 120, maximum: 800), spacing: 10)
    ]


    var body: some View {
        Group {
            if devices.isEmpty {
                DevicesUnavailableView(presentingDevicePairing: $presentingDevicePairing)
            } else {
                ScrollView(.vertical) {
                    LazyVGrid(columns: gridItems) {
                        ForEach(devices) { device in
                            Button {
                                // TODO: implement!
                            } label: {
                                VStack {
                                    Text(device.name)
                                        .foregroundStyle(.primary)
                                    (device.icon?.image ?? Image(systemName: "sensor"))
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundStyle(.accent) // set accent color if one uses sf symbols
                                        .symbolRenderingMode(.hierarchical) // set symbol rendering mode if one uses sf symbols
                                        .accessibilityHidden(true)
                                        .padding([.leading, .trailing], 10) // TODO: fixed size
                                }
                            }
                            .padding(16)
                            .background {
                                RoundedRectangle(cornerSize: CGSize(width: 25, height: 25))
                                    .foregroundStyle(Color(uiColor: .systemBackground))
                            }
                        }
                    }
                    .padding([.leading, .trailing], 20)
                }
                .background(Color(uiColor: .systemGroupedBackground))
            }
        }
        .navigationTitle("Devices")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add Device", systemImage: "plus") {
                    presentingDevicePairing = true
                }
            }
        }
    }


    init(devices: [PairedDeviceInfo], presentingDevicePairing: Binding<Bool>) {
        self.devices = devices
        self._presentingDevicePairing = presentingDevicePairing
    }
}


#if DEBUG
#Preview {
    NavigationStack {
        DevicesGrid(devices: [], presentingDevicePairing: .constant(false))
    }
}

#Preview {
    let devices = [
        PairedDeviceInfo(id: UUID(), name: "BP5250", model: OmronModel.bp5250, icon: .asset("Omron-BP5250")),
        PairedDeviceInfo(id: UUID(), name: "SC-150", model: OmronModel.sc150, icon: .asset("Omron-SC-150"))
    ]

    return NavigationStack {
        DevicesGrid(devices: devices, presentingDevicePairing: .constant(false))
    }
}
#endif
