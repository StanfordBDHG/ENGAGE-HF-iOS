//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Spezi
@_spi(TestingSupport) import SpeziAccount
import SpeziBluetooth
import SpeziDevicesUI
import SpeziLicense
import SpeziViews
import SwiftUI


struct AdditionalAccountSections: View {
    @Environment(Account.self) private var account: Account?
    @Binding var questionnaireId: String?
    
    var body: some View {
        if !(account?.details?.disabled ?? false)
            && account?.details?.selfManaged ?? false {
            Section {
                Button {
                    questionnaireId = "dataUpdate_en_US"
                } label: {
                    Text("Update data")
                }
            }
        }
        Section {
            if !(account?.details?.disabled ?? false) {
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
            }
            NavigationLink {
                DevicesView(appName: ENGAGEHF.appName ?? "ENGAGE") {
                    Text("Hold down the Bluetooth button for 3 seconds to put the device into pairing mode.")
                }
                    .bluetoothScanningOptions(advertisementStaleInterval: 15)
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


#Preview {
    NavigationStack {
        List {
            AdditionalAccountSections(questionnaireId: .constant(nil))
                .previewWith(standard: ENGAGEHFStandard()) {
                    AccountConfiguration(service: InMemoryAccountService())
                }
        }
    }
}
