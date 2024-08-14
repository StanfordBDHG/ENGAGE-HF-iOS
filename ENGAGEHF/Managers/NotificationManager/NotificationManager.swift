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
import UserNotifications


class NotificationManager: Module, NotificationHandler, NotificationTokenHandler, EnvironmentAccessible {
    @Application(\.registerRemoteNotifications) private var registerRemoteNotifications
    @Dependency(NavigationManager.self) private var navigationManager
    
    private let logger = Logger(subsystem: "ENGAGEHF", category: "NotificationManager")
    
    
    func configure() {}
    
    
    func handleNotificationAction(_ response: UNNotificationResponse) async {
        print(#function)
        let payload = response.notification.request.content.userInfo["action"] as? String
        await _ = navigationManager.execute(MessageAction(from: payload))
    }
    
    func handleNotificationsAllowed() async throws {
        print(#function)
        let deviceToken = try await registerRemoteNotifications()
        
        self.configureRemoteNotifications(using: deviceToken)
    }
    
    func receiveUpdatedDeviceToken(_ deviceToken: Data) {
        print(#function)
        self.configureRemoteNotifications(using: deviceToken)
    }
    
    private func configureRemoteNotifications(using deviceToken: Data) {
        print(#function)
        self.logger.debug("Registering device for remote notifications.")
        let registerDevice = Functions.functions().httpsCallable("registerDevice")
        
        Task {
            do {
                _ = try await registerDevice.call(NotificationRegistrationSchema(deviceToken))
                self.logger.debug("Successfully registered device for remote notifications.")
            } catch {
                self.logger.error("Failed to register device for remote notifications: \(error)")
            }
        }
    }
}
