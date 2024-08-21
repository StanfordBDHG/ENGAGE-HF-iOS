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
struct NotificationSettings: Codable, Equatable {
    var receivesAppointmentReminders: Bool
    var receivesMedicationUpdates: Bool
    var receivesQuestionnaireReminders: Bool
    var receivesRecommendationUpdates: Bool
    var receivesVitalsReminders: Bool
    var receivesWeightAlerts: Bool
    
    
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
    
    
    init(
        receivesAppointmentReminders: Bool = true,
        receivesMedicationUpdates: Bool = true,
        receivesQuestionnaireReminders: Bool = true,
        receivesRecommendationUpdates: Bool = true,
        receivesVitalsReminders: Bool = true,
        receivesWeightAlerts: Bool = true
    ) {
        self.receivesAppointmentReminders = receivesAppointmentReminders
        self.receivesMedicationUpdates = receivesMedicationUpdates
        self.receivesQuestionnaireReminders = receivesQuestionnaireReminders
        self.receivesRecommendationUpdates = receivesRecommendationUpdates
        self.receivesVitalsReminders = receivesVitalsReminders
        self.receivesWeightAlerts = receivesWeightAlerts
    }
}


extension NotificationSettings {
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // NOTE: If no setting is found, defaults to false, but the user can still toggle the setting on from the client.
        self.receivesAppointmentReminders = try container.decodeIfPresent(Bool.self, forKey: .receivesAppointmentReminders) ?? false
        self.receivesMedicationUpdates = try container.decodeIfPresent(Bool.self, forKey: .receivesMedicationUpdates) ?? false
        self.receivesQuestionnaireReminders = try container.decodeIfPresent(Bool.self, forKey: .receivesQuestionnaireReminders) ?? false
        self.receivesRecommendationUpdates = try container.decodeIfPresent(Bool.self, forKey: .receivesRecommendationUpdates) ?? false
        self.receivesVitalsReminders = try container.decodeIfPresent(Bool.self, forKey: .receivesVitalsReminders) ?? false
        self.receivesWeightAlerts = try container.decodeIfPresent(Bool.self, forKey: .receivesWeightAlerts) ?? false
    }
}
