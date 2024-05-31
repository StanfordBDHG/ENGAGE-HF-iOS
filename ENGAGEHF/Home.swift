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
import SpeziViews
import SwiftUI


struct HomeView: View {
    enum Tabs: String {
        case home
    }
    
    static var accountEnabled: Bool {
        !FeatureFlags.disableFirebase && !FeatureFlags.skipOnboarding
    }
    
    private var bluetoothEnabled: Bool {
        !ProcessInfo.processInfo.isPreviewSimulator
    }
    
    
    @Environment(MeasurementManager.self) private var measurementManager
    @Environment(WeightScaleDevice.self) private var weightScale: WeightScaleDevice?
    @Environment(Bluetooth.self) private var bluetooth
    
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
        }
            .autoConnect(enabled: bluetoothEnabled, with: bluetooth)
            .sheet(isPresented: $presentingAccount) {
                AccountSheet()
            }
            .accountRequired(Self.accountEnabled) {
                AccountSheet()
            }
            .verifyRequiredAccountDetails(Self.accountEnabled)
            .sheet(
                isPresented: $measurementManager.showSheet,
                onDismiss: {
                    measurementManager.clear()
                },
                content: {
                    MeasurementRecordedView()
                }
            )
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
            Bluetooth {
                Discover(WeightScaleDevice.self, by: .advertisedService(WeightScaleService.self))
            }
        }
}
#endif
