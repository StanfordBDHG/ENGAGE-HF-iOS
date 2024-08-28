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
import SpeziViews
import SwiftUI
import UserNotifications


@Observable
@MainActor
class NotificationManager: Module, NotificationHandler, NotificationTokenHandler, EnvironmentAccessible {
    @ObservationIgnored @Application(\.registerRemoteNotifications) private var registerRemoteNotifications
    @ObservationIgnored @Application(\.unregisterRemoteNotifications) private var unregisterRemoteNotifications
    @ObservationIgnored @Dependency(AccountNotifications.self) private var accountNotifications: AccountNotifications?
    @ObservationIgnored @Application(\.logger) private var logger
    @ObservationIgnored @Dependency(NavigationManager.self) private var navigationManager
    
    @ObservationIgnored @AppStorage(StorageKeys.onboardingFlowComplete) private var completedOnboardingFlow = false
    @ObservationIgnored @Environment(Account.self) private var account: Account?
    
    
    private var cancellable: AnyCancellable?
    private var notificationsTask: Task<Void, Never>?
    
    private var apnsDeviceToken: Data?
    
    var notificationsAuthorized: Bool = false
    var state: ViewState = .idle
    
    
    func configure() {
        self.cancellable = NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification).sink { _ in
            if self.completedOnboardingFlow {
                Task {
                    try await self.checkNotificationsAuthorized()
                }
            }
        }
        
        guard completedOnboardingFlow else {
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
                        do {
                            _ = try await self.requestNotificationPermissions()
                        } catch {
                            self.state = .error(
                                AnyLocalizedError(
                                    error: error,
                                    defaultErrorDescription: "Unable to register for remote notifications."
                                )
                            )
                        }
                    case let .disassociatingAccount(details):
                        do {
                            _ = try await self.unregisterDeviceToken(self.apnsDeviceToken)
                            self.apnsDeviceToken = nil
                        } catch {
                            self.state = .error(
                                AnyLocalizedError(
                                    error: error,
                                    defaultErrorDescription: "Unable to unregister for remote notifications."
                                )
                            )
                        }
                    default:
                        break
                    }
                }
            }
        }
        
        Task {
            try await self.checkNotificationsAuthorized()
        }
    }
    
    
    @MainActor
    func checkNotificationsAuthorized() async throws {
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
        logger.debug("Requesting notification permissions.")
        
        let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        
        guard granted else {
            return false
        }
        
        try await self.handleNotificationsAllowed()
        return true
    }
    
    
    func handleNotificationsAllowed() async throws {
        logger.debug("Notification permissions granted, registering device token.")
        
        let deviceToken = FeatureFlags.skipRemoteNotificationRegistration ? Data() : try await registerRemoteNotifications()
        
        try await self.configureRemoteNotifications(using: deviceToken)
        self.apnsDeviceToken = deviceToken
    }
    
    
    func receiveUpdatedDeviceToken(_ deviceToken: Data) {
        Task {
            do {
                try await self.configureRemoteNotifications(using: deviceToken)
            } catch {
                self.logger.error("Failed to configured remote notifications for updated device token: \(error)")
                self.state = .error(
                    AnyLocalizedError(
                        error: error,
                        defaultErrorDescription: "Unable to unregister for remote notifications."
                    )
                )
            }
        }
    }
    
    
    private func configureRemoteNotifications(using deviceToken: Data) async throws {
        self.logger.debug("Registering device for remote notifications.")
        
        let registerDevice = Functions.functions().httpsCallable("registerDevice")
        _ = try await registerDevice.call(NotificationRegistrationSchema(deviceToken).codingRepresentation)
        
        self.logger.debug("Successfully registered device for remote notifications.")
    }
    
    
    private func unregisterDeviceToken(_ token: Data?) async throws {
        self.logger.debug("Unregistering device for remote notifications.")
        
        guard let token else {
            return
        }
        
        let unregisterDevice = Functions.functions().httpsCallable("unregisterDevice")
        _ = try await unregisterDevice.call(NotificationRegistrationSchema(token).codingRepresentation)
        
        unregisterRemoteNotifications()
        
        self.logger.debug("Successfully unregistered device for remote notifications.")
    }
}
