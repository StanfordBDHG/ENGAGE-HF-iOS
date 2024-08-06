//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount
import SpeziBluetooth
import SpeziBluetoothServices
import SpeziDevices
import SpeziDevicesUI
import SpeziOnboarding
import SpeziViews
import SwiftUI


struct HomeView: View {
    enum Tabs: String {
        case home
        case heart
        case medications
        case education
        case devices
    }
    
    static var accountEnabled: Bool {
        !FeatureFlags.disableFirebase && !FeatureFlags.skipOnboarding
    }
    
    // Disable bluetooth in preview to prevent preview from crashing
    private var bluetoothEnabled: Bool {
        !ProcessInfo.processInfo.isPreviewSimulator
    }

    
    @Environment(HealthMeasurements.self) private var measurements
    @Environment(Bluetooth.self) private var bluetooth
    @Environment(ENGAGEHFStandard.self) private var standard

    @Environment(\.dismiss) private var dismiss
    
    @AppStorage(StorageKeys.homeTabSelection) private var selectedTab = Tabs.home
    @State private var presentingAccount = false
    

    var body: some View {
        @Bindable var measurements = measurements

        TabView(selection: $selectedTab) {
            Dashboard(presentingAccount: $presentingAccount)
                .tag(Tabs.home)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            HeartHealth(presentingAccount: $presentingAccount)
                .tag(Tabs.heart)
                .tabItem {
                    Label("Heart Health", systemImage: "heart")
                }
            Medications(presentingAccount: $presentingAccount)
                .tag(Tabs.medications)
                .tabItem {
                    Label("Medications", systemImage: "pill.fill")
                }
            Education(presentingAccount: $presentingAccount)
                .tag(Tabs.education)
                .tabItem {
                    Label("Education", systemImage: "brain")
                }
            NavigationStack {
                DevicesView(appName: ENGAGEHF.appName ?? "ENGAGE") {
                    Text("Hold down the Bluetooth button for 3 seconds to put the device into pairing mode.")
                }
                    .bluetoothScanningOptions(advertisementStaleInterval: 15)
            }
                .tag(Tabs.devices)
                .tabItem {
                    Label("Devices", systemImage: "sensor.fill")
                }
        }
            .sheet(isPresented: $presentingAccount) {
                AccountSheet()
            }
            .accountRequired(Self.accountEnabled) {
                AccountSetupSheet()
            }
            .verifyRequiredAccountDetails(Self.accountEnabled)
            .sheet(isPresented: $measurements.shouldPresentMeasurements) {
                MeasurementsRecordedSheet { samples in
                    try await standard.addMeasurement(samples: samples)
                }
            }
    }
}


#if DEBUG
#Preview {
    CommandLine.arguments.append("--disableFirebase")
    return HomeView()
        .previewWith(standard: ENGAGEHFStandard()) {
            AccountConfiguration {
                MockUserIdPasswordAccountService()
            }
            HealthMeasurements()
            MessageManager()
            PairedDevices()
            ConfigureTipKit()
            Bluetooth {}
            VitalsManager()
            NavigationManager()
            VideoManager()
            MedicationsManager()
        }
}
#endif
