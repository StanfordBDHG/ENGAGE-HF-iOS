//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Combine
import FirebaseFunctions
import Foundation
import OSLog
import Spezi
import SpeziAccount
import SpeziFoundation
import SwiftUI
import UserNotifications


@Observable
@MainActor
class NotificationManager: Module, NotificationHandler, NotificationTokenHandler, EnvironmentAccessible {
    @ObservationIgnored @Application(\.registerRemoteNotifications) private var registerRemoteNotifications
    @ObservationIgnored @Dependency(AccountNotifications.self) private var accountNotifications: AccountNotifications?
    @ObservationIgnored @Application(\.logger) private var logger
    @ObservationIgnored @Dependency(NavigationManager.self) private var navigationManager
    
    @ObservationIgnored @AppStorage(StorageKeys.onboardingFlowComplete) private var completedOnboardingFlow = false
    @ObservationIgnored @Environment(Account.self) private var account: Account?
    
    
    private var cancellable: AnyCancellable?
    private var notificationsTask: Task<Void, Never>?
    var notificationsAuthorized: Bool = false
    
    
    func configure() {
        if account != nil {
            self.cancellable = NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification).sink { _ in
                self.checkNotificationsAuthorized()
            }
        }
        
        guard completedOnboardingFlow else {
            print("Onboarding false")
            return
        }
        
        if let accountNotifications {
            notificationsTask = Task.detached { @MainActor [weak self] in
                for await event in accountNotifications.events {
                    guard let self else {
                        return
                    }

                    switch event {
                    case let .associatedAccount(details):
                        Task {
                            try await self.requestNotificationPermissions()
                        }
                    // TODO: If user signs out, call an `unregisterRemoteNotifications` cloud function
                    default:
                        break
                    }
                }
            }
        }
        
        self.checkNotificationsAuthorized()
    }
    
    
    private func checkNotificationsAuthorized() {
        Task { @MainActor in
            let systemNotificationSettings = await UNUserNotificationCenter.current().notificationSettings()
            
            switch systemNotificationSettings.authorizationStatus {
            case .denied:
                self.notificationsAuthorized = false
            case .notDetermined:
                self.notificationsAuthorized = try await self.requestNotificationPermissions()
            default:
                self.notificationsAuthorized = true
            }
        }
    }
    
    
    func handleNotificationAction(_ response: UNNotificationResponse) async {
        /// The server should store the action payload to be accessed here. For example:
        /// {
        ///     "aps": {
        ///         "alert": {
        ///             "title": "Medication Uptitration",
        ///             "body": "There has been a change in your medications."
        ///        }
        ///     },
        ///     "action": "medications"
        /// }
        let payload = response.notification.request.content.userInfo["action"] as? String
        await _ = navigationManager.execute(MessageAction(from: payload))
    }
    
    
    /// Requests authorization for remote notifications, displaying an alert if necessary. Returns true if permission was granted, and false otherwise.
    func requestNotificationPermissions() async throws -> Bool {
        let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        
        guard granted else {
            return false
        }
        
        try await self.handleNotificationsAllowed()
        return true
    }
    
    func handleNotificationsAllowed() async throws {
        let deviceToken = FeatureFlags.skipRemoteNotificationRegistration ? Data() : try await registerRemoteNotifications()
        
        try await self.configureRemoteNotifications(using: deviceToken)
    }
    
    func receiveUpdatedDeviceToken(_ deviceToken: Data) {
        Task {
            do {
                try await self.configureRemoteNotifications(using: deviceToken)
            } catch {
                self.logger.error("Failed to configured remote notifications for updated device token: \(error)")
            }
        }
    }
    
    
    private func configureRemoteNotifications(using deviceToken: Data) async throws {
        self.logger.debug("Registering device for remote notifications.")
        
        let registerDevice = Functions.functions().httpsCallable("registerDevice")
        _ = try await registerDevice.call(NotificationRegistrationSchema(deviceToken).codingRepresentation)
        
        self.logger.debug("Successfully registered device for remote notifications.")
    }
}
