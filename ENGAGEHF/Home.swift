//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Spezi
@_spi(TestingSupport) import SpeziAccount
import SpeziBluetooth
import SpeziBluetoothServices
import SpeziDevices
import SpeziDevicesUI
import SpeziViews
import SwiftUI


struct HomeView: View {
    enum Tabs: String, CaseIterable, Hashable {
        case home
        case heart
        case medications
        case education
        case device
        case test
    }

    
    @Environment(HealthMeasurements.self) private var measurements
    @Environment(ENGAGEHFStandard.self) private var standard
    @Environment(NavigationManager.self) private var navigationManager
    @Environment(NotificationManager.self) private var notificationManager
    @Environment(Account.self) private var account: Account?
    @Environment(PairedDevices.self) private var pairedDevices

    @State private var presentingAccount = false
    

    var body: some View {
        @Bindable var measurements = measurements
        @Bindable var navigationManager = navigationManager
        @Bindable var notificationManager = notificationManager

        Group { // swiftlint:disable:this closure_body_length
            if account?.details?.disabled ?? false {
                StudyConcluded(presentingAccount: $presentingAccount)
            } else {
                TabView(selection: $navigationManager.selectedTab) {
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
                    .tag(Tabs.device)
                    .tabItem {
                        Label("Devices", systemImage: "sensor")
                    }
                }
            }
        }
            .sheet(isPresented: $navigationManager.showHealthSummary) {
                HealthSummaryView()
            }
            .sheet(item: $navigationManager.questionnaireId) { questionnaireId in
                QuestionnaireSheetView(questionnaireId: questionnaireId)
            }
            .sheet(isPresented: $presentingAccount) {
                AccountSheet()
            }
            .sheet(isPresented: $measurements.shouldPresentMeasurements) {
                MeasurementsRecordedSheet { samples in
                    try await standard.addMeasurement(samples: samples)
                }
            }
            .viewStateAlert(state: $notificationManager.state)
            .onAppear {
                if #available(iOS 18, *) {
                    if pairedDevices.needsAccessorySetupKitMigration {
                        pairedDevices.showAccessoryMigration()
                    }
                }
            }
    }
}


#if DEBUG
#Preview("Home") {
    HomeView()
        .previewWith(standard: ENGAGEHFStandard()) {
            AccountConfiguration(service: InMemoryAccountService())
            HealthMeasurements()
            MessageManager()
            PairedDevices()
            ConfigureTipKit()
            Bluetooth {}
            VitalsManager()
            NavigationManager()
            VideoManager()
            MedicationsManager()
            NotificationManager()
        }
}

#Preview("Home - Disabled") {
    var details = AccountDetails()
    details.userId = "lelandstanford@stanford.edu"
    details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
    details.disabled = true

    return HomeView()
        .previewWith(standard: ENGAGEHFStandard()) {
            AccountConfiguration(service: InMemoryAccountService(), activeDetails: details)
            HealthMeasurements()
            NavigationManager()
            NotificationManager()
        }
}
#endif
