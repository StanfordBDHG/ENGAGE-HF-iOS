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
    private struct NotificationTokenTimeoutError: LocalizedError {
        var errorDescription: String? {
            "Remote notification registration timed out."
        }
    }
    
    
    @ObservationIgnored @Application(\.registerRemoteNotifications) private var registerRemoteNotifications
    @ObservationIgnored @Dependency(AccountNotifications.self) private var accountNotifications: AccountNotifications?
    @ObservationIgnored @Application(\.logger) private var logger
    @ObservationIgnored @Dependency(NavigationManager.self) private var navigationManager
    
    @ObservationIgnored @AppStorage(StorageKeys.onboardingFlowComplete) private var completedOnboardingFlow = false
    @ObservationIgnored @Environment(Account.self) private var account: Account?
    
    
    private var cancellable: AnyCancellable?
    private var notificationsTask: Task<Void, Never>?
    
    var notificationsAuthorized: Bool = false
    var state: ViewState = .idle
    
    
    func configure() {
        self.cancellable = NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification).sink { _ in
            if self.completedOnboardingFlow {
                Task {
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

                    switch event {
                    case .associatedAccount:
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
                    case .disassociatingAccount:
                        do {
                            _ = try await self.unregisterDeviceToken()
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
            await self.checkNotificationsAuthorized()
        }
    }
    
    
    @MainActor
    func checkNotificationsAuthorized() async {
        let systemNotificationSettings = await UNUserNotificationCenter.current().notificationSettings()
        
        switch systemNotificationSettings.authorizationStatus {
        case .denied:
            self.notificationsAuthorized = false
        case .notDetermined:
            do {
                self.notificationsAuthorized = try await self.requestNotificationPermissions()
            } catch let error as TimeoutError {
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
        await _ = navigationManager.execute(MessageAction(from: payload))
    }
    
    
    /// Requests authorization for remote notifications (displaying an alert if necessary), and registers the device for remote notifications if granted.
    /// Returns true if permission was granted, and false otherwise.
    func requestNotificationPermissions() async throws -> Bool {
        logger.debug("Requesting notification permissions.")
        
        let deviceToken = try await self.getDeviceToken(askPermissionIfNeeded: true)
        
        guard let deviceToken else {
            return false
        }
        
        try await self.configureRemoteNotifications(using: deviceToken)
        return true
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
    
    
    private func unregisterDeviceToken() async throws {
        self.logger.debug("Unregistering device for remote notifications.")
        
        guard let deviceToken = try await self.getDeviceToken(askPermissionIfNeeded: false) else {
            return
        }
        
        let unregisterDevice = Functions.functions().httpsCallable("unregisterDevice")
        _ = try await unregisterDevice.call(NotificationRegistrationSchema(deviceToken).codingRepresentation)
        
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
        return Data()
#else
        return FeatureFlags.skipRemoteNotificationRegistration ? Data() : try await registerRemoteNotifications()
#endif
    }
}
