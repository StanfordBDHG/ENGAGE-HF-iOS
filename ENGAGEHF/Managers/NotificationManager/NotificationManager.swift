//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFunctions
import Foundation
import OSLog
import Spezi
import SwiftUI
import UserNotifications


class NotificationManager: Module, NotificationHandler, NotificationTokenHandler, EnvironmentAccessible {
    @Application(\.registerRemoteNotifications) private var registerRemoteNotifications
    @Application(\.logger) private var logger
    @Dependency(NavigationManager.self) private var navigationManager
    
    
    func configure() {}
    
    
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
    
    func handleNotificationsAllowed() async throws {
        let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        
        guard granted else {
            return
        }
        
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
