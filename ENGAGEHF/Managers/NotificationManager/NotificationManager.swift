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
    @Dependency(NavigationManager.self) private var navigationManager
    
    private let logger = Logger(subsystem: "ENGAGEHF", category: "NotificationManager")
    
    
    func configure() {}
    
    
    func handleNotificationAction(_ response: UNNotificationResponse) async {
        let payload = response.notification.request.content.userInfo["action"] as? String
        await _ = navigationManager.execute(MessageAction(from: payload))
    }
    
    func handleNotificationsAllowed() async throws {
        let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        
        guard granted else {
            return
        }
        
#if !targetEnvironment(simulator)
        let deviceToken = try await registerRemoteNotifications()
#else
        let deviceToken = Data()
#endif
        self.configureRemoteNotifications(using: deviceToken)
    }
    
    func receiveUpdatedDeviceToken(_ deviceToken: Data) {
        self.configureRemoteNotifications(using: deviceToken)
    }
    
    
    private func configureRemoteNotifications(using deviceToken: Data) {
        self.logger.debug("Registering device for remote notifications.")
        let registerDevice = Functions.functions().httpsCallable("registerDevice")
        
        Task {
            do {
                _ = try await registerDevice.call(NotificationRegistrationSchema(deviceToken).codingRepresentation)
                self.logger.debug("Successfully registered device for remote notifications.")
            } catch {
                self.logger.error("Failed to register device for remote notifications: \(error)")
            }
        }
    }
}
