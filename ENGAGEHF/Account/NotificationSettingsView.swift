//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziAccount
import SpeziViews
import SwiftUI

@MainActor
struct NotificationSettingsView: View {
    @Environment(Account.self) private var account
    @Environment(NotificationManager.self) private var notificationManager
    @State private var viewState = ViewState.idle
    
    
    var body: some View {
        List {
            if !self.notificationManager.notificationsAuthorized {
                AsyncButton("Enable Notifications in Settings") {
                    // Create the URL that deep links to notification settings.
                    if let url = URL(string: UIApplication.openNotificationSettingsURLString),
                       UIApplication.shared.canOpenURL(url) {
                        // Ask the system to open that URL.
                        await UIApplication.shared.open(url)
                    }
                }
            }
            
            Group {
                remindersSection
                updatesSection
                trendsSection
            }
                .disabled(!self.notificationManager.notificationsAuthorized)
        }
            .task {
                await notificationManager.checkNotificationsAuthorized()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ProgressView()
                        .opacity(viewState == .processing ? 1 : 0)
                        .animation(.default, value: viewState)
                }
            }
            .navigationTitle("Notifications")
            .viewStateAlert(state: $viewState)
    }
    
    private var remindersSection: some View {
        Section {
            toggleRow("Appointments", for: AccountKeys.receivesAppointmentReminders)
            toggleRow("Inactivity", for: AccountKeys.receivesInactivityReminders)
            toggleRow("Survey", for: AccountKeys.receivesQuestionnaireReminders)
            toggleRow("Vitals", for: AccountKeys.receivesVitalsReminders)
        } header: {
            Text("Reminders")
        } footer: {
            Text("Receive reminders for appointments (one day before), symptom surveys, and vital measurements.")
        }
    }
    
    private var updatesSection: some View {
        Section {
            toggleRow("Medications", for: AccountKeys.receivesMedicationUpdates)
            toggleRow("Recommendations", for: AccountKeys.receivesRecommendationUpdates)
        } header: {
            Text("Updates")
        } footer: {
            Text("Receive updates when current medications and medication recommendations change.")
        }
    }
    
    private var trendsSection: some View {
        Section {
            toggleRow("Weight Trends", for: AccountKeys.receivesWeightAlerts)
        } header: {
            Text("Trends")
        } footer: {
            Text("Receive notifications of changes in vital trends.")
        }
    }
    
    private func toggleRow<Key: AccountKey>(_ title: String, for key: Key.Type) -> some View where Key.Value == Bool {
        Toggle(title, isOn: account.detailsBinding(for: key, viewState: $viewState))
    }
}


#Preview {
    NotificationSettingsView()
        .previewWith(standard: ENGAGEHFStandard()) {
            UserMetaDataManager()
            NotificationManager()
        }
}
