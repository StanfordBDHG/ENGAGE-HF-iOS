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
    @State private var contacts: [Contact] = []
    @State private var viewState: ViewState = .processing
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewState == .idle {
                    if !contacts.isEmpty {
                        ContactsList(contacts: contacts)
                    } else {
                        ContentUnavailableView("No Contacts Available", systemImage: "phone")
                            .background(Color(.systemGroupedBackground))
                    }
                }
            }
                .navigationTitle(String(localized: "CONTACTS_NAVIGATION_TITLE"))
                .task {
                    viewState = .processing
                    await self.getContacts()
                    viewState = .idle
                }
        }
    }
    
    
    private func getContacts() async {
        guard let userDocRef = try? Firestore.userDocumentReference else {
            await ENGAGEHF.logger.error("Failed to access contact information: User not signed in.")
            return
        }
        
        guard let organizationId = (try? await userDocRef.getDocument(as: OrganizationIdentifier.self))?.organization else {
            await ENGAGEHF.logger.warning("No organization found for \(userDocRef.documentID).")
            return
        }
        
        let organizationDocRef = Firestore.organizationCollectionReference.document(organizationId)
        
        do {
            let organizationInfo = try await organizationDocRef.getDocument(as: OrganizationInformation.self)
            self.contacts = [organizationInfo.contact]
        } catch {
            await ENGAGEHF.logger.error("Failed to fetch contact information for organization \(organizationId): \(error)")
        }
    }
}


#if DEBUG
#Preview {
    Contacts()
}
#endif
