//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

@_spi(TestingSupport) import SpeziAccount
import SpeziBluetooth
import SpeziBluetoothServices
import SpeziDevices
import SpeziDevicesUI
import SpeziOnboarding
import SpeziViews
import SwiftUI


struct HomeView: View {
    enum Tabs: String, CaseIterable, Hashable {
        case home
        case heart
        case medications
        case education
        case devices
    }

    
    // Disable bluetooth in preview to prevent preview from crashing
    private var bluetoothEnabled: Bool {
        !ProcessInfo.processInfo.isPreviewSimulator
    }

    
    @Environment(HealthMeasurements.self) private var measurements
    @Environment(Bluetooth.self) private var bluetooth
    @Environment(ENGAGEHFStandard.self) private var standard
    @Environment(NavigationManager.self) private var navigationManager

    @Environment(\.dismiss) private var dismiss
    
    @State private var presentingAccount = false
    

    var body: some View {
        @Bindable var measurements = measurements
        @Bindable var navigationManager = navigationManager

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
                .tag(Tabs.devices)
                .tabItem {
                    Label("Devices", systemImage: "sensor.fill")
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
            .accountRequired(!FeatureFlags.disableFirebase && !FeatureFlags.skipOnboarding) {
                AccountSetupSheet()
            }
            .sheet(isPresented: $measurements.shouldPresentMeasurements) {
                MeasurementsRecordedSheet { samples in
                    try await standard.addMeasurement(samples: samples)
                }
            }
    }
}


#if DEBUG
#Preview {
    var details = AccountDetails()
    details.userId = "lelandstanford@stanford.edu"
    details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")

    return HomeView()
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
        }
}
#endif
