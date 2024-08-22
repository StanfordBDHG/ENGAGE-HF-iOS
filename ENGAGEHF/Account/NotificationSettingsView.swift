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


struct NotificationSettingsView: View {
    @Environment(NotificationManager.self) private var notificationManager
    @Environment(UserMetaDataManager.self) private var userMetaDataManager
    
    
    var body: some View {
        @Bindable var userMetaDataManager = userMetaDataManager
        let notificationSettings = $userMetaDataManager.notificationSettings
        
        List {
            Group {
                Section {
                    Toggle("Appointments", isOn: notificationSettings.receivesAppointmentReminders)
                    Toggle("Survey", isOn: notificationSettings.receivesQuestionnaireReminders)
                    Toggle("Vitals", isOn: notificationSettings.receivesVitalsReminders)
                } header: {
                    Text("Reminders")
                } footer: {
                    Text("Receive reminders for appointments (one day before), symptom surveys, and vital measurements.")
                }
                Section {
                    Toggle("Medications", isOn: notificationSettings.receivesMedicationUpdates)
                    Toggle("Recommendations", isOn: notificationSettings.receivesRecommendationUpdates)
                } header: {
                    Text("Updates")
                } footer: {
                    Text("Receive updates when current medications and medication recommendations change.")
                }
                Section {
                    Toggle("Weight Trends", isOn: notificationSettings.receivesWeightAlerts)
                } header: {
                    Text("Trends")
                } footer: {
                    Text("Receive notifications of changes in vital trends.")
                }
            }
                .disabled(!self.notificationManager.notificationsAuthorized)
            if !self.notificationManager.notificationsAuthorized {
                AsyncButton("Enable Notifications in Settings") {
                    // Create the URL that deep links to notification settings.
                    if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
                        // Ask the system to open that URL.
                        await UIApplication.shared.open(url)
                    }
                }
            }
        }
            .onChange(of: userMetaDataManager.notificationSettings) {
                Task {
                    await userMetaDataManager.pushUpdatedNotificationSettings()
                }
            }
            .navigationTitle("Notifications")
    }
}


#Preview {
    NotificationSettingsView()
        .previewWith(standard: ENGAGEHFStandard()) {
            UserMetaDataManager()
            NotificationManager()
        }
}
