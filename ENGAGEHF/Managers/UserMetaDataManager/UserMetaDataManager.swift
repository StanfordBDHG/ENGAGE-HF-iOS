//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import Foundation
import Spezi
import SpeziAccount
import SpeziFirebaseAccount


@Observable
@MainActor
class UserMetaDataManager: Module, EnvironmentAccessible {
    @ObservationIgnored @Dependency(Account.self) private var account: Account?
    @ObservationIgnored @Dependency(AccountNotifications.self) private var accountNotifications: AccountNotifications?
    @ObservationIgnored @Dependency(FirebaseAccountService.self) private var accountService: FirebaseAccountService?

    @Application(\.logger) @ObservationIgnored private var logger
    
    private var snapshotListener: ListenerRegistration?
    private var notificationsTask: Task<Void, Never>?
    
    private(set) var organization: OrganizationInformation?
    
    var notificationSettings = NotificationSettings()
    
    
    func configure() {
        if ProcessInfo.processInfo.isPreviewSimulator {
            return
        }
        
        // Clear away any previous user's organization so that we do not skip fetching the organization info
        // for the newly-signed in user.
        self.organization = nil
        
        // On sign in, store the user's organization and message settings
        if let accountNotifications {
            notificationsTask = Task.detached { @MainActor [weak self] in
                for await event in accountNotifications.events {
                    guard let self else {
                        return
                    }

                    switch event {
                    case let .associatedAccount(details):
                        updateSnapshotListener(for: details)
                    case .disassociatingAccount:
                        updateSnapshotListener(for: nil)
                    default:
                        break
                    }
                }
            }
        }
        
        if let account {
            updateSnapshotListener(for: account.details)
        }
    }
    
    
    /// Call on change of notification settings in Account Sheet.
    /// Updates the user's notification settings in Firestore to the current values stored in the manager.
    func pushUpdatedNotificationSettings() async {
        self.logger.debug("Updating notification settings.")
        
        guard let details = account?.details else {
            return
        }
        
        print(self.notificationSettings.codingRepresentation)
        
        let userDocRef = Firestore.userDocumentReference(for: details.accountId)
        
        do {
            try await userDocRef.updateData(self.notificationSettings.codingRepresentation)
        } catch {
            self.logger.error("Failed to update notification settings: \(error)")
            return
        }
    }
    
    
    /// Called on sign-in. Registers a snapshot listener to the user's meta-data document in Firestore.
    /// Collects information such as notification preferences and organization contact information.
    private func updateSnapshotListener(for details: AccountDetails?) {
        self.logger.debug("Initializing user information snapshot listener...")
        
        self.snapshotListener?.remove()
        
        guard let details else {
            return
        }
        
        let userDocRef = Firestore.userDocumentReference(for: details.accountId)
        
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
                
                // Only fetch organization information from Firestore if we haven't already fetched it
                // for the current user.
                if self.organization == nil {
                    Task { @MainActor in
                        await self.getOrganizationInfo(from: userDoc)
                    }
                }
                
                // Decode message settings
                // Defaults to true if field not present in firestore, and ignores unknown fields
                do {
                    self.notificationSettings = try userDoc.data(as: NotificationSettings.self)
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
    
    
    deinit {
        _notificationsTask?.cancel()
    }
}
