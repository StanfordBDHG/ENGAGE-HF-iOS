//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

@_spi(TestingSupport) import SpeziAccount
import SpeziBluetooth
import SpeziDevicesUI
import SpeziLicense
import SpeziViews
import SwiftUI


struct AdditionalAccountSections: View {
    @Environment(Account.self) private var account: Account?
    @Environment(\.editMode) private var editMode
    @Binding var presentSheet: Bool

    var body: some View {
        Section {
            let phoneNumbers = account?.details?.phoneNumbers ?? []
            ForEach(phoneNumbers, id: \.self) { phoneNumber in
                Text(phoneNumber)
            }
            .onDelete { indexSet in
                let value = phoneNumbers
                for index in indexSet {
                    // TODO: Think about possibly showing an alert when delete fails
                    // TODO: phoneNumberViewModel.delete(value[index])
                }
            }
            
            if editMode?.wrappedValue == .active {
                Button("Add new phone number") {
                    presentSheet = true
                }
            }
        } header: {
            Text("Phone numbers")
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


#Preview {
    NavigationStack {
        List {
            AdditionalAccountSections(presentSheet: .constant(false))
                .previewWith(standard: ENGAGEHFStandard()) {
                    AccountConfiguration(service: InMemoryAccountService())
                }
        }
    }
}
