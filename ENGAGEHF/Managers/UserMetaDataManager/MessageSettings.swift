//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


/// The user's preferences for whether or not to receive each type of Push Notification
struct MessageSettings: Codable, Equatable {
    var receivesAppointmentReminders = true
    var receivesMedicationUpdates = true
    var receivesQuestionnaireReminders = true
    var receivesRecommendationUpdates = true
    var receivesVitalsReminders = true
    var receivesWeightAlerts = true
    
    
    var codingRepresentation: [String: Bool] {
        [
            CodingKeys.receivesAppointmentReminders.stringValue: receivesAppointmentReminders,
            CodingKeys.receivesMedicationUpdates.stringValue: receivesMedicationUpdates,
            CodingKeys.receivesQuestionnaireReminders.stringValue: receivesQuestionnaireReminders,
            CodingKeys.receivesRecommendationUpdates.stringValue: receivesRecommendationUpdates,
            CodingKeys.receivesVitalsReminders.stringValue: receivesVitalsReminders,
            CodingKeys.receivesWeightAlerts.stringValue: receivesWeightAlerts
        ]
    }
}


extension MessageSettings {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.receivesAppointmentReminders = try container.decodeIfPresent(Bool.self, forKey: .receivesAppointmentReminders) ?? false
        self.receivesAppointmentReminders = try container.decodeIfPresent(Bool.self, forKey: .receivesMedicationUpdates) ?? false
        self.receivesAppointmentReminders = try container.decodeIfPresent(Bool.self, forKey: .receivesQuestionnaireReminders) ?? false
        self.receivesAppointmentReminders = try container.decodeIfPresent(Bool.self, forKey: .receivesRecommendationUpdates) ?? false
        self.receivesAppointmentReminders = try container.decodeIfPresent(Bool.self, forKey: .receivesVitalsReminders) ?? false
        self.receivesAppointmentReminders = try container.decodeIfPresent(Bool.self, forKey: .receivesWeightAlerts) ?? false
    }
}
