//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import BluetoothServices
import SpeziAccount
import SpeziBluetooth
import SpeziOnboarding
import SpeziViews
import SwiftUI


struct HomeView: View {
    enum Tabs: String {
        case home
        case education
    }
    
    static var accountEnabled: Bool {
        !FeatureFlags.disableFirebase && !FeatureFlags.skipOnboarding
    }
    
    // Disable bluetooth in preview to prevent preview from crashing
    private var bluetoothEnabled: Bool {
        !ProcessInfo.processInfo.isPreviewSimulator
    }

    
    @Environment(MeasurementManager.self) private var measurementManager
    @Environment(WeightScaleDevice.self) private var weightScale: WeightScaleDevice?
    @Environment(Bluetooth.self) private var bluetooth
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage(StorageKeys.homeTabSelection) private var selectedTab = Tabs.home
    @State private var presentingAccount = false
    
    
    var body: some View {
        @Bindable var measurementManager = measurementManager
        
        TabView(selection: $selectedTab) {
            Dashboard(presentingAccount: $presentingAccount)
                .tag(Tabs.home)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            Education(presentingAccount: $presentingAccount)
                .tag(Tabs.education)
                .tabItem {
                    Label("Education", systemImage: "brain")
                }
        }
            .autoConnect(enabled: bluetoothEnabled, with: bluetooth)
            .sheet(isPresented: $presentingAccount) {
                AccountSheet()
            }
            .accountRequired(Self.accountEnabled) {
                OnboardingStack {
                    InvitationCodeView()
                    AccountSetup { _ in
                        dismiss()
                    } header: {
                        AccountSetupHeader()
                    }
                }
            }
            .verifyRequiredAccountDetails(Self.accountEnabled)
            .sheet(item: $measurementManager.newMeasurement) { measurement in
                MeasurementRecordedView(measurement: measurement)
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
            MeasurementManager()
            NotificationManager()
            Bluetooth {
                Discover(WeightScaleDevice.self, by: .advertisedService(WeightScaleService.self))
            }
        }
}
#endif
