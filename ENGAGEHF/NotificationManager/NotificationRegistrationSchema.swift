//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import class UIKit.UIDevice


/// The parameters used to register the device for remote notifications from the server.
struct NotificationRegistrationSchema: Codable {
    let notificationToken: String
    let platform: String
    let osVersion: String?
    let appVersion: String?
    let appBuild: String?
    let language: String?
    let timeZone: String?
    
    
    init(_ deviceToken: Data, using locale: Locale = Locale.current) {
        self.notificationToken = deviceToken.reduce(into: "") { $0 += String(format: "%02.2hhx", $1) }
        self.platform = "iOS"
        self.osVersion = UIDevice.current.systemVersion
        self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        self.appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        self.language = locale.identifier
        self.timeZone = locale.timeZone?.identifier
    }
}
