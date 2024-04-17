//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount
import SwiftUI


struct HomeView: View {
    enum Tabs: String {
        case home
        case bluetooth
    }
    
    static var accountEnabled: Bool {
        !FeatureFlags.disableFirebase && !FeatureFlags.skipOnboarding
    }


    @AppStorage(StorageKeys.homeTabSelection) private var selectedTab = Tabs.home
    @State private var presentingAccount = false

    
    var body: some View {
        TabView(selection: $selectedTab) {
            Dashboard(presentingAccount: $presentingAccount)
                .tag(Tabs.home)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            FindDevicesView()
                .tag(Tabs.bluetooth)
                .tabItem {
                    Label("Device", systemImage: "antenna.radiowaves.left.and.right.circle.fill")
                }
        }
            .sheet(isPresented: $presentingAccount) {
                AccountSheet()
            }
            .accountRequired(Self.accountEnabled) {
                AccountSheet()
            }
            .verifyRequiredAccountDetails(Self.accountEnabled)
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
