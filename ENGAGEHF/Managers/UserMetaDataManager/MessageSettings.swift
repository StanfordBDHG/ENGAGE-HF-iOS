//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


struct MessageSettings: Codable {
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
        
        self.receivesAppointmentReminders = try container.decodeIfPresent(Bool.self, forKey: .receivesAppointmentReminders) ?? true
        self.receivesMedicationUpdates = try container.decodeIfPresent(Bool.self, forKey: .receivesMedicationUpdates) ?? true
        self.receivesQuestionnaireReminders = try container.decodeIfPresent(Bool.self, forKey: .receivesQuestionnaireReminders) ?? true
        self.receivesRecommendationUpdates = try container.decodeIfPresent(Bool.self, forKey: .receivesRecommendationUpdates) ?? true
        self.receivesVitalsReminders = try container.decodeIfPresent(Bool.self, forKey: .receivesVitalsReminders) ?? true
        self.receivesWeightAlerts = try container.decodeIfPresent(Bool.self, forKey: .receivesWeightAlerts) ?? true
    }
}
