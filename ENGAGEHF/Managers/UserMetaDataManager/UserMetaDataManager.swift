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
    @ObservationIgnored @Application(\.logger) private var logger
    
    private var snapshotListener: ListenerRegistration?
    private var notificationsTask: Task<Void, Never>?
    private var previousOrganizationId: String?
    
    private(set) var organization: Organization?
    
    
    func configure() {
        if ProcessInfo.processInfo.isPreviewSimulator {
            return
        }
        
        if let accountNotifications {
            notificationsTask = Task.detached { @MainActor [weak self] in
                for await event in accountNotifications.events {
                    guard let self else {
                        return
                    }
                    
                    updateOrganizationIfNeeded(id: event.accountDetails?.organization)
                }
            }
        }
        
        if let account {
            updateOrganizationIfNeeded(id: account.details?.organization)
        }
    }
    
    private func updateOrganizationIfNeeded(id organizationId: String?) {
        guard previousOrganizationId != organizationId else {
            return
        }
        previousOrganizationId = organizationId
        organization = nil
        guard let organizationId else {
            return
        }
        let organizationDocRef = Firestore.organizationCollectionReference.document(organizationId)
        Task { @MainActor in
            do {
#if TEST
                if FeatureFlags.setupTestUserMetaData {
                    self.organization = .testOrganization
                    self.logger.debug("Injected test organization.")
                    return
                }
#endif
                self.organization = try await organizationDocRef.getDocument(as: Organization.self)
                self.logger.debug("Successfully fetched organization information.")
            } catch {
                self.logger.error("Failed to fetch contact information for organization \(organizationId): \(error)")
            }
        }
    }
    
    
    deinit {
        _notificationsTask?.cancel()
    }
}
