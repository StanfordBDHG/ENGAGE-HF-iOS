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


struct PairingSheet: View { // TOOD: move and preview! (with tips!)
    @Environment(Bluetooth.self) private var bluetooth
    @Environment(DeviceManager.self) private var deviceManager

    @State private var path = NavigationPath()

    var body: some View {
        @Bindable var deviceManager = deviceManager

        NavigationStack(path: $path) {
            DevicesGrid(devices: deviceManager.pairedDevices, navigation: $path, presentingDevicePairing: $deviceManager.presentingDevicePairing)
                .scanNearbyDevices(enabled: deviceManager.scanningNearbyDevices, with: bluetooth) // automatically search if no devices are paired
                .sheet(isPresented: $deviceManager.presentingDevicePairing) {
                    AccessorySetupSheet(deviceManager.pairableDevice)
                }
                .navigationDestination(for: PairedDeviceInfo.self) { device in
                    DeviceDetailsView(device)
                }
        }
    }
}


// TODO: rename to PaneContent?
struct PairDeviceView: View {
    private let descriptor: AccessoryDescriptor
    private let session: PairingSession
    private let pairClosure: () async throws -> Void

    @Environment(DeviceManager.self) private var deviceManager
    @Environment(\.dismiss) private var dismiss


    var body: some View {
        @Bindable var session = session

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
            .symbolRenderingMode(.hierarchical) // set symbol rendering mode if one uses sf symbols
            .frame(maxWidth: 250, maxHeight: 120) // TODO: image are a bit too small?
        Spacer()

        Label("Successfully Paired", systemImage: "checkmark.circle.fill")
            .padding(.bottom, 6)
            .foregroundStyle(.primary, .green)
            .opacity(session.paired ? 1 : 0)
            .accessibilityHidden(!session.paired) // TODO: better way to handle this?

        AsyncButton(state: $session.viewState) {
            if session.paired {
                dismiss()
                return
            }

            do {
                try await pairClosure()
                session.paired = true
            } catch {
                print(error) // TODO: logger?
                throw error
            }
        } label: {
            Text(session.paired ? "Done" : "Pair")
                .frame(maxWidth: .infinity, maxHeight: 35)
        }
            .buttonStyle(.borderedProminent)
            .padding([.leading, .trailing], 36)
    }


    init(descriptor: AccessoryDescriptor, session: PairingSession, pair: @escaping () async throws -> Void) {
        self.descriptor = descriptor
        self.session = session
        self.pairClosure = pair
    }
}


struct DiscoveryView: View {
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


struct FailureContentView: View {
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


struct DismissButton: View { // TODO: SpeziViews? SpeziDevices?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button {
            dismiss()
        } label: {
            // TODO: increased button area?
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

@Observable
class PairingSession {
    var device: (any OmronHealthDevice)?

    var paired = false
    var viewState: ViewState = .idle // TODO: OperationState?

    init(_ device: (any OmronHealthDevice)? = nil) {
        self.device = device
        self.paired = paired
        self.viewState = viewState
    }
}


struct AccessorySetupSheet: View {
    @Environment(DeviceManager.self) private var deviceManager
    @Environment(\.dismiss) private var dismiss

    @State private var session: PairingSession

    var body: some View {
        NavigationStack {
            VStack {
                if case let .error(error) = session.viewState {
                    FailureContentView(error)
                } else if let device = session.device {
                    let descriptor = AccessoryDescriptor(id: device.id, name: device.label, image: device.icon?.image ?? Image(systemName: "sensor"))
                    PairDeviceView(descriptor: descriptor, session: session) {
                        try await device.pair() // TODO: also reset pairable device on error (or only if it is still advertising?)
                        deviceManager.registerPairedDevice(device)
                    }
                } else { // TODO: make its own view?
                    DiscoveryView()
                }
            }
                .toolbar {
                    DismissButton()
                }
        }
            .presentationDetents([.medium])
            .presentationCornerRadius(25)
            .interactiveDismissDisabled() // TODO: allow in "discovery mode"?#
            .onChange(of: deviceManager.pairableDevice?.id) { oldValue, newValue in
                guard oldValue == nil && session.device == nil else {
                    return
                }
                // TODO: should it replace a previous advertisement (that is now gone?)
                session.device = deviceManager.pairableDevice
            }
    }

    init(_ device: (any OmronHealthDevice)?) {
        self._session = State(wrappedValue: PairingSession(device))
    }
}


#if DEBUG
// TODO: inject devices as modules?
#Preview {
    Text(verbatim: "")
        .sheet(isPresented: .constant(true)) {
            AccessorySetupSheet(BloodPressureCuffDevice.createMockDevice(state: .disconnected))
        }
        .previewWith {
            DeviceManager()
        }
}


#Preview {
    Text(verbatim: "")
        .sheet(isPresented: .constant(true)) {
            AccessorySetupSheet(WeightScaleDevice.createMockDevice(state: .disconnected)) // TODO: image doesnt match!
        }
        .previewWith {
            DeviceManager()
        }
}

#Preview {
    Text(verbatim: "")
        .sheet(isPresented: .constant(true)) {
            AccessorySetupSheet(nil)
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
                        Button("Close") {}
                    }
            }
                .presentationDetents([.medium]) // TODO: how to inject into Sheet view?
                .presentationCornerRadius(25)
        }
}
#endif
