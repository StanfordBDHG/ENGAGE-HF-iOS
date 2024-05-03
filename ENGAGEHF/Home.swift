//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount
import SpeziBluetooth
import SwiftUI


struct HomeView: View {
    enum Tabs: String {
        case home
        case bluetooth
    }
    
    static var accountEnabled: Bool {
        !FeatureFlags.disableFirebase && !FeatureFlags.skipOnboarding
    }

    
    @Environment(WeightScaleDevice.self) private var weightScale: WeightScaleDevice?
    @Environment(Bluetooth.self) private var bluetooth
    @State private var measurementManager = MeasurementManager.manager
    
    @AppStorage(StorageKeys.homeTabSelection) private var selectedTab = Tabs.home
    @State private var presentingAccount = false
    
    var presentSheet: Bool {
        measurementManager.state == .processing || weightScale != nil
    }
    
    var body: some View {
        @Bindable var measurementManager = measurementManager
        
        TabView(selection: $selectedTab) {
            Dashboard(presentingAccount: $presentingAccount)
                .tag(Tabs.home)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
        }
            .autoConnect(enabled: weightScale == nil, with: bluetooth)
            
            .sheet(isPresented: $presentingAccount) {
                AccountSheet()
            }
            .accountRequired(Self.accountEnabled) {
                AccountSheet()
            }
            .verifyRequiredAccountDetails(Self.accountEnabled)
        
            .sheet(isPresented: $measurementManager.showSheet) {
                VStack {
                    Text("Measurement recorded: \(measurementManager.newMeasurement?.quantity.description ?? "Unknown")")
                    Text("Date: \(measurementManager.newMeasurement?.startDate.formatted() ?? "Unknown")")
                }
            }
    }
}


#Preview {
    CommandLine.arguments.append("--disableFirebase")
    return HomeView()
        .previewWith(standard: ENGAGEHFStandard()) {
            AccountConfiguration {
                MockUserIdPasswordAccountService()
            }
        }
}
