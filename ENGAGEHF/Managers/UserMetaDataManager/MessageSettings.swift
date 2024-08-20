//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


/// Defines the possible entry points for updating the message settings.
/// Each case corresponds to a settings present in MessageSettings and includes a keyPath to access a binding to the field.
enum MessageSettingsStoragePaths: CaseIterable {
    case receivesAppointmentReminders
    case receivesMedicationUpdates
    case receivesQuestionnaireReminders
    case receivesRecommendationUpdates
    case receivesVitalsReminders
    case receivesWeightAlerts
    
    
    var title: String {
        switch self {
        case .receivesAppointmentReminders: "Appointment Reminders"
        case .receivesMedicationUpdates: "Medication Updates"
        case .receivesQuestionnaireReminders: "Questionnaire Reminders"
        case .receivesRecommendationUpdates: "Recommendation Updates"
        case .receivesVitalsReminders: "Vitals Reminders"
        case .receivesWeightAlerts: "Weight Trends"
        }
    }
    
    var hint: String {
        switch self {
        case .receivesAppointmentReminders: "Choose whether or not to receive appointment reminders one day before each appointment."
        case .receivesMedicationUpdates: "Choose whether or not to receive updates about medication changes."
        case .receivesQuestionnaireReminders: "Choose whether or not to receive reminders when symptom surveys are available (every two weeks)."
        case .receivesRecommendationUpdates: "Choose whether or not to receive updates about changes in medication recommendations."
        case .receivesVitalsReminders: "Choose whether or not to receive reminders to take vital measurements."
        case .receivesWeightAlerts: "Choose whether or not to receive notifications of changes in vital trends."
        }
    }
    
    var storagePath: KeyPath<Binding<MessageSettings>, Binding<Bool>> {
        switch self {
        case .receivesAppointmentReminders: \.receivesAppointmentReminders
        case .receivesMedicationUpdates: \.receivesMedicationUpdates
        case .receivesQuestionnaireReminders: \.receivesQuestionnaireReminders
        case .receivesRecommendationUpdates: \.receivesRecommendationUpdates
        case .receivesVitalsReminders: \.receivesVitalsReminders
        case .receivesWeightAlerts: \.receivesWeightAlerts
        }
    }
}


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
        
        self.receivesAppointmentReminders = try container.decodeIfPresent(Bool.self, forKey: .receivesAppointmentReminders) ?? true
        self.receivesMedicationUpdates = try container.decodeIfPresent(Bool.self, forKey: .receivesMedicationUpdates) ?? true
        self.receivesQuestionnaireReminders = try container.decodeIfPresent(Bool.self, forKey: .receivesQuestionnaireReminders) ?? true
        self.receivesRecommendationUpdates = try container.decodeIfPresent(Bool.self, forKey: .receivesRecommendationUpdates) ?? true
        self.receivesVitalsReminders = try container.decodeIfPresent(Bool.self, forKey: .receivesVitalsReminders) ?? true
        self.receivesWeightAlerts = try container.decodeIfPresent(Bool.self, forKey: .receivesWeightAlerts) ?? true
    }
}
