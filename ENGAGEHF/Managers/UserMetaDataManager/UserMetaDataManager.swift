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
    private var snapshotListener: ListenerRegistration?
    private let logger = Logger(subsystem: "ENGAGEHF", category: "UserDataManager")
    
    private(set) var organization: OrganizationInformation?
    private(set) var messageSettings = MessageSettings()
    
    
    func configure() {
        // On sign in, store the user's organization and message settings
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, _ in
            self?.registerSnapshotListener()
        }
    }
    
    
    func updateMessageSettings() async {
        self.logger.debug("Updating message preferences.")
        
        guard let userDocRef = try? Firestore.userDocumentReference else {
            self.logger.error("Failed to update message settings: User not signed in.")
            return
        }
        
        do {
            try await userDocRef.updateData(self.messageSettings.codingRepresentation)
        } catch {
            self.logger.error("Failed to update message settings: \(error)")
            return
        }
    }
    
    
    private func registerSnapshotListener() {
        self.logger.debug("Initializing user information snapshot listener...")
        
        self.snapshotListener?.remove()
        
        guard let userDocRef = try? Firestore.userDocumentReference else {
            self.logger.error("Failed to initialize user information snapshot: User not signed in.")
            return
        }
        
        self.snapshotListener = userDocRef
            .addSnapshotListener { docSnapshot, error in
                if let error {
                    self.logger.error("Failed to initialize user information snapshot: \(error)")
                    return
                }
                
                self.logger.debug("Fetching user metadata.")
                
                guard let userDoc = docSnapshot else {
                    self.logger.error("No document found in user document snapshot.")
                    return
                }
                
                Task {
                    await self.getOrganizationInfo(from: userDoc)
                }
                
                do {
                    self.messageSettings = try userDoc.data(as: MessageSettings.self)
                    self.logger.debug("Successfully fetched message settings.")
                } catch {
                    self.logger.error("Failed to decode message settings: \(error)")
                }
            }
    }
    
    private func getOrganizationInfo(from userDoc: DocumentSnapshot) async {
        self.logger.debug("Fetching organization from \(userDoc.documentID).")
        
        
        let organizationIdWrapper: OrganizationIdentifier
        do {
            organizationIdWrapper = try userDoc.data(as: OrganizationIdentifier.self)
        } catch {
            self.logger.error("Failed to decode organization identifier: \(error)")
            return
        }
        
        guard let organizationId = organizationIdWrapper.organization  else {
            self.logger.error("No organization id found.")
            return
        }
        
        let organizationDocRef = Firestore.organizationCollectionReference.document(organizationId)
        
        do {
            self.organization = try await organizationDocRef.getDocument(as: OrganizationInformation.self)
            self.logger.debug("Successfully fetched organization information.")
        } catch {
            self.logger.error("Failed to fetch contact information for organization \(organizationId): \(error)")
        }
    }
}
