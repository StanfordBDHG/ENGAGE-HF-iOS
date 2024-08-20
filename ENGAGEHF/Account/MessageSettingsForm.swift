//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct MessageSettingsSection: View {
    @Environment(UserMetaDataManager.self) private var userMetaDataManager
    
    
    var body: some View {
        @Bindable var userMetaDataManager = userMetaDataManager
        
        Section(header: Text("Notifications")) {
            ForEach(MessageSettingsStoragePaths.allCases, id: \.self) { messageSetting in
                VStack(alignment: .leading) {
                    Toggle(messageSetting.title, isOn: $userMetaDataManager.messageSettings[keyPath: messageSetting.storagePath])
                    Text(messageSetting.hint)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
            .onChange(of: userMetaDataManager.messageSettings) {
                Task {
                    await userMetaDataManager.updateMessageSettings()
                }
            }
    }
}


#Preview {
    MessageSettingsSection()
        .previewWith(standard: ENGAGEHFStandard()) {
            UserMetaDataManager()
        }
}
