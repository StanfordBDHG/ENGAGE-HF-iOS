//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import ACarousel
import SpeziViews
import SwiftUI


struct PairDeviceView<Collection: RandomAccessCollection>: View where Collection.Element == any PairableDevice {
    private let devices: Collection
    private let pairClosure: (any PairableDevice) async throws -> Void

    @Environment(\.dismiss) private var dismiss

    @Binding private var pairingState: PairingState
    @State private var selectedDeviceIndex: Int = 0

    @AccessibilityFocusState private var isHeaderFocused: Bool

    private var selectedDevice: (any PairableDevice)? {
        guard selectedDeviceIndex < devices.count else {
            return nil
        }
        let index = devices.index(devices.startIndex, offsetBy: selectedDeviceIndex) // TODO: compare that against end index?
        return devices[index]
    }

    private var selectedDeviceName: String {
        selectedDevice.map { "\"\($0.label)\"" } ?? "the accessory"
    }

    var body: some View {
        PaneContent(title: "Pair Accessory", subtitle: "Do you want to pair \(selectedDeviceName) with the ENGAGE app?") {
            if devices.count > 1 {
                ACarousel(devices, id: \.id, index: $selectedDeviceIndex, spacing: 0, headspace: 0) { device in
                    AccessoryImageView(device)
                }
                .frame(maxHeight: 150)
                CarouselDots(count: devices.count, selectedIndex: $selectedDeviceIndex)
            } else if let device = devices.first {
                AccessoryImageView(device)
            }
        } action: {
            AsyncButton {
                guard let selectedDevice else {
                    return
                }

                guard case .discovery = pairingState else {
                    return
                }

                pairingState = .pairing

                do {
                    try await pairClosure(selectedDevice)
                    pairingState = .paired(selectedDevice)
                } catch {
                    print(error) // TODO: logger?
                    pairingState = .error(AnyLocalizedError(error: error))
                }
            } label: {
                Text("Pair")
                    .frame(maxWidth: .infinity, maxHeight: 35)
            }
            .buttonStyle(.borderedProminent)
            .padding([.leading, .trailing], 36)
        }
    }


    init(devices: Collection, state: Binding<PairingState>, pair: @escaping (any PairableDevice) async throws -> Void) {
        self.devices = devices
        self._pairingState = state
        self.pairClosure = pair
    }
}


#if DEBUG
#Preview {
    SheetPreview {
        PairDeviceView(devices: [BloodPressureCuffDevice.createMockDevice(state: .disconnected)], state: .constant(.discovery)) { _ in
        }
    }
}

#Preview {
    SheetPreview {
        let device: [any OmronHealthDevice] = [
            BloodPressureCuffDevice.createMockDevice(state: .disconnected),
            WeightScaleDevice.createMockDevice(state: .disconnected)
        ]
        PairDeviceView(devices: device, state: .constant(.discovery)) { _ in
        }
    }
}
#endif
