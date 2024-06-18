//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import BluetoothViews
import SpeziBluetooth
import SpeziViews
import SwiftUI


struct DevicesGrid: View {
    private let devices: [PairedDeviceInfo]


    @Binding private var presentingDevicePairing: Bool


    private var gridItems = [
        GridItem(.adaptive(minimum: 120, maximum: 800), spacing: 10),
        GridItem(.adaptive(minimum: 120, maximum: 800), spacing: 10)
    ]


    var body: some View {
        // TODO: swiftlint disable
        Group { // swiftlint:disable:this closure_body_length
            if devices.isEmpty {
                ContentUnavailableView {
                    Text("No Devices")
                        .fontWeight(.semibold)
                } description: {
                    Text("Paired devices will appear here once paired.")
                } actions: {
                    Button("Pair New Device") {
                        presentingDevicePairing = true
                    }
                }
            } else {
                ScrollView(.vertical) {
                    LazyVGrid(columns: gridItems) {
                        ForEach(devices) { device in
                            Button {

                            } label: {
                                VStack {
                                    Text(device.name)
                                    Image("Omron-\(device.model.rawValue)")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .padding([.leading, .trailing], 10)
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


#Preview {
    NavigationStack {
        DevicesGrid(devices: [], presentingDevicePairing: .constant(false))
    }
}

#Preview {
    let devices = [
        PairedDeviceInfo(id: UUID(), name: "BP5250", model: .bp5250, lastSequenceNumber: nil, userDatabaseNumber: nil),
        PairedDeviceInfo(id: UUID(), name: "SC150", model: .sc150, lastSequenceNumber: nil, userDatabaseNumber: nil)
    ]

    return NavigationStack {
        DevicesGrid(devices: devices, presentingDevicePairing: .constant(false))
    }
}


struct PairingSheet: View {
    @Environment(Bluetooth.self) private var bluetooth
    @Environment(DeviceManager.self) private var deviceManager

    @State private var navigationPath = NavigationPath()

    var body: some View {
        @Bindable var deviceManager = deviceManager

        NavigationStack(path: $navigationPath) {
            DevicesGrid(devices: deviceManager.pairedDevices, presentingDevicePairing: $deviceManager.presentingDevicePairing)
                .scanNearbyDevices(enabled: deviceManager.pairedDevices.isEmpty, with: bluetooth) // automatically search if no devices are paired
                .sheet(isPresented: $deviceManager.presentingDevicePairing) {
                    AccessorySetupSheet(deviceManager.pairableDevice)
                }
                // TODO: plus button/search button toolbar!
        }
    }
}

struct AccessoryDescriptor {
    let id: UUID
    let name: String
    let image: Image
}


struct PairDeviceContent: View {
    private let descriptor: AccessoryDescriptor
    private let pairClosure: () async throws -> Void

    @Environment(DeviceManager.self) private var deviceManager
    @Environment(\.dismiss) private var dismiss

    @Binding private var viewState: ViewState
    @State private var paired = false


    var body: some View {
        VStack {
            Text("Pair Accessory")
                .bold()
                .font(.largeTitle)
            Text("Do you want to pair \"\(descriptor.name)\" with the ENGAGE app?")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
            .padding([.leading, .trailing], 12)
            .multilineTextAlignment(.center)

        Spacer()
        descriptor.image // TODO: dark mode images!
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(.accent) // set accent color if one uses sf symbols
            .frame(maxWidth: 250, maxHeight: 120) // TODO: image are a bit too small?
        Spacer()

        Label("Successfully Paired", systemImage: "checkmark.circle.fill")
            .padding(.bottom, 6)
            .foregroundStyle(.primary, .green) // TODO: optimize color
            .opacity(paired ? 1 : 0)
            .accessibilityHidden(!paired) // TODO: better way to handle this?

        AsyncButton(state: $viewState) {
            if paired {
                dismiss()
                return
            }

            do {
                try await pairClosure()
                paired = true
            } catch {
                print(error) // TODO: logger?
                throw error
            }
        } label: {
            Text(paired ? "Done" : "Pair")
                .frame(maxWidth: .infinity, maxHeight: 35)
        }
            .buttonStyle(.borderedProminent)
            .padding([.leading, .trailing], 36)
            .onDisappear {
                if paired {
                    // TODO: this needs better infrastructure!
                    deviceManager.clearPairableDevice()
                }
            }
    }


    init(descriptor: AccessoryDescriptor, state: Binding<ViewState>, pair: @escaping () async throws -> Void) {
        self.descriptor = descriptor
        self._viewState = state
        self.pairClosure = pair
    }
}


struct DiscoveringContent: View {
    var body: some View {
        VStack {
            Text("Discovering")
                .bold()
                .font(.largeTitle)
            Text("Hold down the Bluetooth button for 3 seconds to put the device into pairing mode.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
            .padding([.leading, .trailing], 20)
            .multilineTextAlignment(.center)

        Spacer()
        ProgressView()
            .controlSize(.large)
        Spacer()
    }
}


struct FailureContent: View {
    private let error: any LocalizedError

    private var message: String {
        error.failureReason ?? error.errorDescription
            ?? String(localized: "Failed to pair accessory.")
    }

    @Environment(\.dismiss) private var dismiss


    var body: some View {
        VStack {
            Text("Pairing Failed")
                .bold()
                .font(.largeTitle)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
            .padding([.leading, .trailing], 20)
            .multilineTextAlignment(.center)

        Spacer()
        Image(systemName: "exclamationmark.triangle.fill")
            .symbolRenderingMode(.hierarchical)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .accessibilityHidden(true)
            .frame(maxWidth: 250, maxHeight: 120)
            .foregroundStyle(.red)
        Spacer()

        Button {
            dismiss()
        } label: {
            Text("OK")
                .frame(maxWidth: .infinity, maxHeight: 35)
        }
            .buttonStyle(.borderedProminent)
            .padding([.leading, .trailing], 36)
    }


    init(_ error: any LocalizedError) {
        self.error = error
    }
}


struct AccessorySetupSheet: View {
    private let device: (any OmronHealthDevice)? // TODO: not let, but onAppear setting @State!

    @Environment(DeviceManager.self) private var deviceManager
    @Environment(\.dismiss) private var dismiss

    @State private var viewState: ViewState = .idle

    var body: some View {
        NavigationStack {
            VStack {
                if case let .error(error) = viewState {
                    FailureContent(error)
                } else if let device {
                    let descriptor = AccessoryDescriptor(id: device.id, name: device.label, image: device.icon)
                    PairDeviceContent(descriptor: descriptor, state: $viewState) {
                        try await device.pair()
                        deviceManager.registerPairedDevice(device)
                    }
                } else { // TODO: make its own view?
                    DiscoveringContent()
                }
            }
            .toolbar {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .accessibilityLabel("Dismiss")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .background {
                            Circle()
                                .fill(Color(uiColor: .secondarySystemBackground))
                                .frame(width: 25, height: 25)
                        }
                }
                    .buttonStyle(.plain)
            }
        }
            .presentationDetents([.medium])
            .presentationCornerRadius(25)
            .interactiveDismissDisabled() // TODO: allow in "discovery mode"?
    }

    init(_ device: (any OmronHealthDevice)?) {
        self.device = device
    }
}


struct GreyButtonStyle: PrimitiveButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            // .font(.system(size: 5, weight: .bold, design: .rounded))
            .foregroundStyle(.secondary)
            .background {
                Circle()
                    .fill(Color(uiColor: .secondarySystemBackground))
                    .frame(width: 25, height: 25)
            }
        /*
         Circle()
         .fill(Color(.secondarySystemBackground))
         .frame(width: 30, height: 30) // You can make this whatever size, but keep UX in mind.
         .overlay(
         Image(systemName: "xmark")
         .font(.system(size: 15, weight: .bold, design: .rounded)) // This should be less than the frame of the circle
         .foregroundColor(.secondary)
         )
         */
    }
}

#if DEBUG
// TODO: inject devices as modules?
#Preview {
    Text(verbatim: " ")
        .sheet(isPresented: .constant(true)) {
            AccessorySetupSheet(BloodPressureCuffDevice.createMockDevice(state: .disconnected))
        }
        .previewWith {
            DeviceManager()
        }
}


#Preview {
    Text(verbatim: " ")
        .sheet(isPresented: .constant(true)) {
            AccessorySetupSheet(WeightScaleDevice.createMockDevice(state: .disconnected)) // TODO: image doesnt match!
        }
        .previewWith {
            DeviceManager()
        }
}

#Preview {
    Text(verbatim: " ")
        .sheet(isPresented: .constant(true)) {
            AccessorySetupSheet(nil)
        }
        .previewWith {
            DeviceManager()
        }
}

#Preview {
    Text(verbatim: " ")
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                VStack {
                    FailureContent(DevicePairingError.notInPairingMode)
                }
                    .toolbar {
                        Button("Close") {}
                    }
            }
                .presentationDetents([.medium]) // TODO: how to inject into Sheet view?
                .presentationCornerRadius(25)
        }
}
#endif
