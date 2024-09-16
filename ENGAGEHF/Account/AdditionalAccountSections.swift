//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziBluetooth
import SpeziDevicesUI
import SpeziLicense
import SwiftUI


struct AdditionalAccountSections: View {
    var body: some View {
        Section {
            NavigationLink {
                HealthSummaryView()
            } label: {
                Text("Health Summary")
            }
            NavigationLink {
                Contacts()
            } label: {
                Text("Contacts")
            }
            NavigationLink {
                NotificationSettingsView()
            } label: {
                Text("Notifications")
            }
            NavigationLink {
                NavigationStack {
                    DevicesView(appName: ENGAGEHF.appName ?? "ENGAGE") {
                        Text("Hold down the Bluetooth button for 3 seconds to put the device into pairing mode.")
                    }
                    .bluetoothScanningOptions(advertisementStaleInterval: 15)
                }
            } label: {
                Text("Bluetooth Devices")
            }
        }
        Section {
            NavigationLink {
                ContributionsList(appName: "ENGAGE-HF", projectLicense: .mit)
            } label: {
                Text("LICENSE_INFO_TITLE")
            }
        }
    }
}
