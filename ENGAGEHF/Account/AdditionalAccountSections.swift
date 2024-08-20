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
        Section(header: Text("Study Information")) {
            NavigationLink {
                Contacts()
            } label: {
                Text("Contacts")
            }
            NavigationLink {
                ContributionsList(appName: "ENGAGE-HF", projectLicense: .mit)
            } label: {
                Text("LICENSE_INFO_TITLE")
            }
        }
        MessageSettingsSection()
        Section {
            NavigationLink {
                HealthSummaryView()
            } label: {
                Text("Health Summary")
            }
        }
    }
}
