//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI
import TipKit


struct DevicesGrid: View {
    @Binding private var devices: [PairedDeviceInfo]
    @Binding private var navigationPath: NavigationPath
    @Binding private var presentingDevicePairing: Bool


    private var gridItems = [
        GridItem(.adaptive(minimum: 120, maximum: 800), spacing: 12),
        GridItem(.adaptive(minimum: 120, maximum: 800), spacing: 12)
    ]


    var body: some View {
        Group {
            if devices.isEmpty {
                ZStack {
                    VStack {
                        TipView(ForgetDeviceTip.instance)
                            .padding([.leading, .trailing], 20)
                        Spacer()
                    }
                    DevicesUnavailableView(presentingDevicePairing: $presentingDevicePairing)
                }
            } else {
                ScrollView(.vertical) {
                    VStack(spacing: 16) {
                        TipView(ForgetDeviceTip.instance)
                            .tipBackground(Color(uiColor: .secondarySystemGroupedBackground))

                        LazyVGrid(columns: gridItems) {
                            ForEach($devices) { device in
                                Button {
                                    navigationPath.append(device)
                                } label: {
                                    DeviceTile(device.wrappedValue)
                                }
                                    .foregroundStyle(.primary)
                            }
                        }
                    }
                        .padding([.leading, .trailing], 20)
                }
                    .background(Color(uiColor: .systemGroupedBackground))
            }
        }
            .navigationTitle("Devices")
            .navigationDestination(for: Binding<PairedDeviceInfo>.self) { deviceInfo in
                DeviceDetailsView(deviceInfo) // TODO: prevents updates :(
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Device", systemImage: "plus") {
                        presentingDevicePairing = true
                    }
                }
            }
    }


    init(devices: Binding<[PairedDeviceInfo]>, navigation: Binding<NavigationPath>, presentingDevicePairing: Binding<Bool>) {
        self._devices = devices
        self._navigationPath = navigation
        self._presentingDevicePairing = presentingDevicePairing
    }
}


// TODO: does that hurt?
extension Binding: Hashable, Equatable where Value: Hashable {
    public static func == (lhs: Binding<Value>, rhs: Binding<Value>) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue)
    }
}


#if DEBUG
#Preview {
    NavigationStack {
        DevicesGrid(devices: .constant([]), navigation: .constant(NavigationPath()), presentingDevicePairing: .constant(false))
    }
        .onAppear {
            Tips.showAllTipsForTesting()
            try? Tips.configure()
        }
        .previewWith {
            DeviceManager()
        }
}

#Preview {
    let devices = [
        PairedDeviceInfo(id: UUID(), name: "BP5250", model: OmronModel.bp5250, icon: .asset("Omron-BP5250")),
        PairedDeviceInfo(id: UUID(), name: "SC-150", model: OmronModel.sc150, icon: .asset("Omron-SC-150"))
    ]

    return NavigationStack {
        DevicesGrid(devices: .constant(devices), navigation: .constant(NavigationPath()), presentingDevicePairing: .constant(false))
    }
        .onAppear {
            Tips.showAllTipsForTesting()
            try? Tips.configure()
        }
        .previewWith {
            DeviceManager()
        }
}
#endif
