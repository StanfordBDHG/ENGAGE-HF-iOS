//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct NotificationSettings: View {
    @Environment(UserMetaDataManager.self) private var userMetaDataManager
    
    
    var body: some View {
        @Bindable var userMetaDataManager = userMetaDataManager
        let messageSettings = $userMetaDataManager.messageSettings
        
        List {
            Section {
                Toggle("Appointments", isOn: messageSettings.receivesAppointmentReminders)
                Toggle("Survey", isOn: messageSettings.receivesQuestionnaireReminders)
                Toggle("Vitals", isOn: messageSettings.receivesVitalsReminders)
            } header: {
                Text("Reminders")
            } footer: {
                Text("Receive reminders for appointments (one day before), symptom surveys, and vital measurements.")
            }
            Section {
                Toggle("Medications", isOn: messageSettings.receivesMedicationUpdates)
                Toggle("Recommendations", isOn: messageSettings.receivesRecommendationUpdates)
            } header: {
                Text("Updates")
            } footer: {
                Text("Receive updates when current medications and medication recommendations change.")
            }
            Section {
                Toggle("Weight Trends", isOn: messageSettings.receivesWeightAlerts)
            } header: {
                Text("Trends")
            } footer: {
                Text("Receive notifications of changes in vital trends.")
            }
        }
            .onChange(of: userMetaDataManager.messageSettings) {
                Task {
                    await userMetaDataManager.updateMessageSettings()
                }
            }
            .navigationTitle("Notifications")
    }
}


#Preview {
    NotificationSettings()
        .previewWith(standard: ENGAGEHFStandard()) {
            UserMetaDataManager()
        }
}
