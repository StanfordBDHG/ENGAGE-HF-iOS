//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import OSLog
import Spezi
import SpeziFirebaseConfiguration


@Observable
class UserMetaDataManager: Module, EnvironmentAccessible {
    @ObservationIgnored @Dependency(ConfigureFirebaseApp.self) private var configureFirebaseApp
    
    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    private let logger = Logger(subsystem: "ENGAGEHF", category: "UserDataManager")
    
    private(set) var organization: OrganizationInformation?
    private(set) var messageSettings: MessageSettings?
    
    
    func configure() {
        // On sign in, store the user's organization and message settings
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let user {
                Task {
                    await self?.getOrganization()
                    await self?.getMessageSettings(user)
                }
            }
        }
    }
    
    
    private func getMessageSettings(_ user: User) async {
        self.logger.debug("Fetching message preferences for user \(user.uid).")
        
        
    }
    
    private func getOrganization() async {
        self.logger.debug("Fetching organization information.")
        
        guard let userDocRef = try? Firestore.userDocumentReference else {
            self.logger.error("Failed to access contact information: User not signed in.")
            return
        }
        
        guard let organizationId = (try? await userDocRef.getDocument(as: OrganizationIdentifier.self))?.organization else {
            self.logger.warning("No organization found for \(userDocRef.documentID).")
            return
        }
        
        let organizationDocRef = Firestore.organizationCollectionReference.document(organizationId)
        
        do {
            let organizationInfo = try await organizationDocRef.getDocument(as: OrganizationInformation.self)
            
            self.organization = organizationInfo
            self.logger.debug("Successfully fetched organization information.")
        } catch {
            self.logger.error("Failed to fetch contact information for organization \(organizationId): \(error)")
        }
    }
}
