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


@Observable
class NotificationManager: Module, NotificationHandler, NotificationTokenHandler, EnvironmentAccessible {
    @ObservationIgnored @Application(\.registerRemoteNotifications) var registerRemoteNotifications
    
    private let logger = Logger(subsystem: "ENGAGEHF", category: "NotificationManager")
    
    
    func configure() {}
    
    
    func handleNotificationsAllowed() async throws {
        let deviceToken = try await registerRemoteNotifications()
        
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
                _ = try await registerDevice.call(NotificationRegistrationSchema(deviceToken))
                self.logger.debug("Successfully registered device for remote notifications.")
            } catch {
                self.logger.error("Faild to register device for remote notifications: \(error)")
            }
        }
    }
}
