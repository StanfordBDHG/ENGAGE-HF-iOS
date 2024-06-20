//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import ACarousel
import BluetoothViews
import SpeziBluetooth
import SpeziViews
import SwiftUI

// TODO: structure pairing UI
// TODO: move sutff into SpeziDevices and abstract everything!

// TODO: 180x120 ASKit dimenaions

struct PaneContent<Content: View, Action: View>: View {
    private let title: Text
    private let subtitle: Text
    private let content: Content
    private let action: Action

    @AccessibilityFocusState private var isHeaderFocused: Bool

    var body: some View {
        VStack {
            VStack {
                title
                    .bold()
                    .font(.largeTitle)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityFocused($isHeaderFocused)
                subtitle
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
                .padding([.leading, .trailing], 20) // TODO: this is 12 in the pair device thingy?
                .multilineTextAlignment(.center)

            Spacer()
            content
            Spacer()

            action
        }
            .onAppear {
                isHeaderFocused = true // TODO: should we do that?
            }
    }

    init(title: Text, subtitle: Text, @ViewBuilder content: () -> Content, @ViewBuilder action: () -> Action = { EmptyView() }) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
        self.action = action()
    }

    init(
        title: LocalizedStringResource,
        subtitle: LocalizedStringResource,
        @ViewBuilder content: () -> Content,
        @ViewBuilder action: () -> Action = { EmptyView() }
    ) {
        self.init(title: Text(title), subtitle: Text(subtitle), content: content, action: action)
    }
}


struct PairedDeviceView: View {
    private let device: any OmronHealthDevice

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        /* // TODO: brink back checkmark/color green for paired screen?
         Label("Successfully Paired", systemImage: "checkmark.circle.fill")
         .padding(.bottom, 6)
         .foregroundStyle(.primary, .green)
         */
        PaneContent(title: "Accessory Paired", subtitle: "\"\(device.label)\" was successfully paired with the ENGAGE app.") {
            AccessoryImageView(device)
        } action: {
            Button {
                dismiss()
            } label: {
                Text("Done")
                    .frame(maxWidth: .infinity, maxHeight: 35)
            }
                .buttonStyle(.borderedProminent)
                .padding([.leading, .trailing], 36)
        }
    }


    init(_ device: any OmronHealthDevice) {
        self.device = device
    }
}


struct AccessoryImageView: View {
    private let device: any OmronHealthDevice

    var body: some View {
        let image = device.icon?.image ?? Image(systemName: "sensor") // swiftlint:disable:this accessibility_label_for_image
        HStack {
            image // TODO: dark mode images!
                .resizable()
                .aspectRatio(contentMode: .fit)
                .accessibilityHidden(true)
                .foregroundStyle(.accent) // set accent color if one uses sf symbols
                .symbolRenderingMode(.hierarchical) // set symbol rendering mode if one uses sf symbols
                .frame(maxWidth: 250, maxHeight: 120)
        }
            .frame(maxWidth: .infinity, maxHeight: 150) // make drag-able area a bit larger
            .background(Color(uiColor: .systemBackground)) // we need to set a non-clear color for it to be drag-able
    }


    init(_ device: any OmronHealthDevice) {
        self.device = device
    }
}


struct PairDeviceView<Collection: RandomAccessCollection>: View where Collection.Element == any OmronHealthDevice {
    private let devices: Collection
    private let pairClosure: (any OmronHealthDevice) async throws -> Void

    @Environment(\.dismiss) private var dismiss

    @Binding private var pairingState: PairingState
    @State private var selectedDeviceIndex: Int = 0

    @AccessibilityFocusState private var isHeaderFocused: Bool

    private var selectedDevice: (any OmronHealthDevice)? {
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


    init(devices: Collection, state: Binding<PairingState>, pair: @escaping (any OmronHealthDevice) async throws -> Void) {
        self.devices = devices
        self._pairingState = state
        self.pairClosure = pair
    }
}


struct CarouselDots: View {
    private let count: Int
    @Binding private var selectedIndex: Int

    private var pageNumber: Binding<Int> {
        .init {
            selectedIndex + 1
        } set: { newValue in
            selectedIndex = newValue - 1
        }
    }

    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .frame(width: 7, height: 7)
                    .foregroundStyle(index == selectedIndex ? .primary : .tertiary)
                    .onTapGesture {
                        withAnimation {
                            selectedIndex = index // TODO: drag slider
                        }
                    }
            }
        }
        .padding(10)
        .background {
            // make sure voice hover highlighter has round corners
            RoundedRectangle(cornerSize: CGSize(width: 5, height: 5))
                .foregroundColor(Color(uiColor: .systemBackground))
        }
        .accessibilityRepresentation {
            Stepper("Page", value: pageNumber, in: 1...count, step: 1)
                .accessibilityValue("Page \(pageNumber.wrappedValue) of \(count)")
        }
    }

    init(count: Int, selectedIndex: Binding<Int>) {
        self.count = count
        self._selectedIndex = selectedIndex
    }
}


struct DiscoveryView: View {
    var body: some View {
        PaneContent(
            title: "Discovering",
            subtitle: "Hold down the Bluetooth button for 3 seconds to put the device into pairing mode."
        ) {
            ProgressView()
                .controlSize(.large)
        }
    }
}


struct FailureContentView: View {
    private let error: any LocalizedError

    private var message: String {
        error.failureReason ?? error.errorDescription
            ?? String(localized: "Failed to pair accessory.")
    }

    @Environment(\.dismiss) private var dismiss


    var body: some View {
        PaneContent(title: Text("Pairing Failed"), subtitle: Text(message)) {
            Image(systemName: "exclamationmark.triangle.fill")
                .symbolRenderingMode(.hierarchical)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .accessibilityHidden(true)
                .frame(maxWidth: 250, maxHeight: 120)
                .foregroundStyle(.red)
        } action: {
            Button {
                dismiss()
            } label: {
                Text("OK")
                    .frame(maxWidth: .infinity, maxHeight: 35)
            }
            .buttonStyle(.borderedProminent)
            .padding([.leading, .trailing], 36)
        }
    }


    init(_ error: any LocalizedError) {
        self.error = error
    }
}


enum PairingState {
    case discovery
    case pairing // processing!
    case paired(any OmronHealthDevice)
    case error(LocalizedError)
}


struct AccessorySetupSheet<Collection: RandomAccessCollection>: View where Collection.Element == any OmronHealthDevice {
    private let devices: Collection

    @Environment(DeviceManager.self) private var deviceManager
    @Environment(\.dismiss) private var dismiss

    @State private var pairingState: PairingState = .discovery

    var body: some View {
        NavigationStack {
            VStack { // TODO: we can remove that later!
                if case let .error(error) = pairingState {
                    FailureContentView(error)
                } else if case let .paired(device) = pairingState {
                    PairedDeviceView(device)
                } else if !devices.isEmpty {
                    PairDeviceView(devices: devices, state: $pairingState) { device in
                        try await device.pair()
                        // TODO: set paired state here?
                        deviceManager.registerPairedDevice(device)
                    }
                } else {
                    DiscoveryView()
                }
            }
                .toolbar { // TODO: where to put that?
                    DismissButton()
                }
        }
            .presentationDetents([.medium])
            .presentationCornerRadius(25)
            .interactiveDismissDisabled()
    }

    init(_ devices: Collection) {
        self.devices = devices
    }
}


#if DEBUG
#Preview {
    Text(verbatim: "")
        .sheet(isPresented: .constant(true)) {
            AccessorySetupSheet([BloodPressureCuffDevice.createMockDevice(state: .disconnected)])
        }
        .previewWith {
            DeviceManager()
        }
}


#Preview {
    Text(verbatim: "")
        .sheet(isPresented: .constant(true)) {
            let devices: [any OmronHealthDevice] = [
                BloodPressureCuffDevice.createMockDevice(state: .disconnected),
                WeightScaleDevice.createMockDevice(state: .disconnected)
            ]
            AccessorySetupSheet(devices)
        }
        .previewWith {
            DeviceManager()
        }
}

#Preview {
    Text(verbatim: "")
        .sheet(isPresented: .constant(true)) {
            AccessorySetupSheet([])
        }
        .previewWith {
            DeviceManager()
        }
}

#Preview {
    Text(verbatim: "")
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                VStack {
                    FailureContentView(DevicePairingError.notInPairingMode)
                }
                    .toolbar {
                        DismissButton()
                    }
            }
                .presentationDetents([.medium]) // TODO: how to inject into Sheet view?
                .presentationCornerRadius(25)
        }
}
#endif
