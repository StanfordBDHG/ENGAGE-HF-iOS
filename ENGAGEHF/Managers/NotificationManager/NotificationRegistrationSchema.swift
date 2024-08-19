//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import class UIKit.UIDevice


enum MobilePlatforms: String {
    case iOS
}


/// The parameters used to register the device for remote notifications from the server.
struct NotificationRegistrationSchema: Codable {
    private let notificationToken: String
    private let platform: String
    private let osVersion: String?
    private let appVersion: String?
    private let appBuild: String?
    private let language: String?
    private let timeZone: String?
    
    
    var codingRepresentation: [String: String?] {
        [
            CodingKeys.notificationToken.stringValue: self.notificationToken,
            CodingKeys.platform.stringValue: self.platform,
            CodingKeys.osVersion.stringValue: self.osVersion,
            CodingKeys.appVersion.stringValue: self.appVersion,
            CodingKeys.appBuild.stringValue: self.appBuild,
            CodingKeys.language.stringValue: self.language,
            CodingKeys.timeZone.stringValue: self.timeZone
        ]
    }
    
    
    init(_ deviceToken: Data, locale: Locale = Locale.current, timeZone: TimeZone = .current) {
        self.notificationToken = deviceToken.reduce(into: "") { $0 += String(format: "%02.2hhx", $1) }
        self.platform = MobilePlatforms.iOS.rawValue
        self.osVersion = UIDevice.current.systemVersion
        self.appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        self.appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        self.language = locale.identifier
        self.timeZone = timeZone.identifier
    }
}
