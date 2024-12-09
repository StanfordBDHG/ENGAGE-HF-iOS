//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Combine
import FirebaseFunctions
import FirebaseMessaging
import Foundation
import OSLog
import Spezi
import SpeziAccount
import SpeziFoundation
import SpeziNotifications
import SpeziViews
import SwiftUI
import UserNotifications


@Observable
@MainActor
final class NotificationManager: Manager, NotificationHandler, NotificationTokenHandler {
    private struct NotificationTokenTimeoutError: LocalizedError {
        var errorDescription: String? {
            "Remote notification registration timed out."
        }
    }
    
    
    @ObservationIgnored @Dependency(AccountNotifications.self) private var accountNotifications: AccountNotifications?
    @ObservationIgnored @Dependency(NavigationManager.self) private var navigationManager
    @ObservationIgnored @Dependency(Account.self) private var account: Account?
    
    @ObservationIgnored @Application(\.registerRemoteNotifications) private var registerRemoteNotifications
    @ObservationIgnored @Application(\.logger) private var logger
    
    @ObservationIgnored @AppStorage(StorageKeys.onboardingFlowComplete) private var completedOnboardingFlow = false
    
    
    private var cancellable: AnyCancellable?
    private var notificationsTask: Task<Void, Never>?
    
    var notificationsAuthorized: Bool = false
    var state: ViewState = .idle
    
    
    nonisolated init() {}
    
    
    func configure() {
        self.cancellable = NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification).sink { _ in
            Task { @MainActor in
                if self.completedOnboardingFlow, self.account != nil {
                    await self.checkNotificationsAuthorized()
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
                  
                    if event.newEnrolledAccountDetails != nil {
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
                    } else if event.accountDetails == nil {
                        _ = try? await self.unregisterDeviceToken()
                    }
                }
            }
        }
        
        Task { @MainActor in
            if self.account != nil {
                await self.checkNotificationsAuthorized()
            }
        }
    }
    
    
    func refreshContent() {
        Task {
            do {
                if account?.details != nil {
                    _ = try await self.requestNotificationPermissions()
                } else {
                    _ = try await self.unregisterDeviceToken()
                }
            } catch {
                self.state = .error(
                    AnyLocalizedError(
                        error: error,
                        defaultErrorDescription: "Unable to register for remote notifications."
                    )
                )
            }
        }
    }
    

    func checkNotificationsAuthorized() async {
        let systemNotificationSettings = await UNUserNotificationCenter.current().notificationSettings()
        
        switch systemNotificationSettings.authorizationStatus {
        case .denied:
            self.notificationsAuthorized = false
        case .notDetermined:
            do {
                self.notificationsAuthorized = try await self.requestNotificationPermissions()
            } catch _ as TimeoutError {
                self.state = .error(NotificationTokenTimeoutError())
            } catch {
                self.state = .error(
                    AnyLocalizedError(
                        error: error,
                        defaultErrorDescription: "Unable to register device for remote notifications."
                    )
                )
            }
        case .authorized, .provisional, .ephemeral:
            self.notificationsAuthorized = true
        default:
            self.notificationsAuthorized = false
        }
    }
    
    
    func receiveIncomingNotification(_ notification: UNNotification) async -> UNNotificationPresentationOptions? {
        [.banner, .list, .sound]
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
        _ = await navigationManager.execute(MessageAction(from: payload))
    }
    
    
    /// Requests authorization for remote notifications (displaying an alert if necessary), and registers the device for remote notifications if granted.
    /// Returns true if permission was granted, and false otherwise.
    func requestNotificationPermissions() async throws -> Bool {
        logger.debug("Requesting notification permissions.")
        
        guard let deviceToken = try await self.getDeviceToken(askPermissionIfNeeded: true) else {
            return false
        }
        
        try await self.registerDeviceToken(using: deviceToken)
        return true
    }
    
    
    func receiveUpdatedDeviceToken(_ apnsToken: Data) {
        Task {
            do {
                try await self.registerDeviceToken(using: apnsToken)
            } catch {
                self.logger.error("Failed to configure remote notifications for updated device token: \(error)")
            }
        }
    }
    
    
    private func registerDeviceToken(using apnsToken: Data) async throws {
        self.logger.debug("Registering device for remote notifications.")
        
        let fcmToken = try await convertTokenToFCM(apns: apnsToken)
        let registerDevice = Functions.functions().httpsCallable("registerDevice")
        _ = try await registerDevice.call(NotificationRegistrationSchema(fcmToken).codingRepresentation)
        
        self.logger.debug("Successfully registered device for remote notifications.")
    }
    
    
    private func unregisterDeviceToken() async throws {
        self.logger.debug("Unregistering device for remote notifications.")
        
        guard let deviceToken = try await self.getDeviceToken(askPermissionIfNeeded: false) else {
            return
        }
        
        let fcmToken = try await convertTokenToFCM(apns: deviceToken)
        let unregisterDevice = Functions.functions().httpsCallable("unregisterDevice")
        _ = try await unregisterDevice.call(NotificationRegistrationSchema(fcmToken).codingRepresentation)
        
        self.logger.debug("Successfully unregistered device for remote notifications.")
    }
    
    
    private func getDeviceToken(askPermissionIfNeeded: Bool = true) async throws -> Data? {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        
        switch settings.authorizationStatus {
        case .notDetermined:
            if askPermissionIfNeeded {
                let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
                
                guard granted else {
                    return nil
                }
                
                break
            } else {
                return nil
            }
        case .authorized, .ephemeral, .provisional:
            break
        case .denied:
            return nil
        default:
            return nil
        }
        
#if TEST
        return nil
#else
        return FeatureFlags.skipRemoteNotificationRegistration ? nil : try await registerRemoteNotifications()
#endif
    }

    private func convertTokenToFCM(apns apnsToken: Data) async throws -> String {
        let messaging = Messaging.messaging()
        messaging.apnsToken = apnsToken
        return try await messaging.token()
    }
}
