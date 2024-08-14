//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import Foundation
import SpeziContact
import SpeziViews
import SwiftUI


/// Displays the contacts for the ENGAGEHF.
struct Contacts: View {
    @Environment(UserMetaDataManager.self) private var userMetaDataManager
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                if let contact = userMetaDataManager.organization?.contact {
                    ContactsList(contacts: [contact])
                } else {
                    ContentUnavailableView("No Contacts Available", systemImage: "phone")
                        .background(Color(.systemGroupedBackground))
                }
            }
                .navigationTitle(String(localized: "CONTACTS_NAVIGATION_TITLE"))
        }
    }
}


#if DEBUG
#Preview {
    Contacts()
}
#endif
