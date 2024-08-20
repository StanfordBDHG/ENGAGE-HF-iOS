//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

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
                NotificationSettings()
            } label: {
                Text("Notifications")
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
