//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziAccount
import SpeziAccountPhoneNumbers
import SwiftUI


// swiftlint:disable attributes discouraged_optional_boolean

extension AccountDetails {
//    @AccountKey(
//        id: "phoneNumbers",
//        name: "Phone Numbers",
//        category: .contactDetails,
//        as: PhoneNumbersArray.self,
//        displayView: PhoneNumberDisplayView.self,
//        entryView: PhoneNumberEntryView.self
//    )
//    var phoneNumbers: PhoneNumbersArray?
//    
    @AccountKey(
        id: "invitationCode",
        name: "Invitation Code",
        category: .other,
        as: String.self,
        initial: .empty("")
    )
    var invitationCode: String?
    
    @AccountKey(
        id: "organization",
        name: "Organization",
        category: .other,
        as: String.self,
        initial: .empty("")
    )
    var organization: String?
    
    @AccountKey(
        id: "receivesAppointmentReminders",
        name: "Appointments",
        category: .other,
        as: Bool.self,
        initial: .default(true)
    )
    var receivesAppointmentReminders: Bool?
    
    @AccountKey(
        id: "receivesInactivityReminders",
        name: "Inactivity",
        category: .other,
        as: Bool.self,
        initial: .default(true)
    )
    var receivesInactivityReminders: Bool?
    
    @AccountKey(
        id: "receivesMedicationUpdates",
        name: "Medications",
        category: .other,
        as: Bool.self,
        initial: .default(true)
    )
    var receivesMedicationUpdates: Bool?
    
    @AccountKey(
        id: "receivesQuestionnaireReminders",
        name: "Survey",
        category: .other,
        as: Bool.self,
        initial: .default(true)
    )
    var receivesQuestionnaireReminders: Bool?
    
    @AccountKey(
        id: "receivesRecommendationUpdates",
        name: "Recommendations",
        category: .other,
        as: Bool.self,
        initial: .default(true)
    )
    var receivesRecommendationUpdates: Bool?
    
    @AccountKey(
        id: "receivesVitalsReminders",
        name: "Vitals",
        category: .other,
        as: Bool.self,
        initial: .default(true)
    )
    var receivesVitalsReminders: Bool?
    
    @AccountKey(
        id: "receivesWeightAlerts",
        name: "Weight Trends",
        category: .other,
        as: Bool.self,
        initial: .default(true)
    )
    var receivesWeightAlerts: Bool?
}

@KeyEntry(\.phoneNumbers)
@KeyEntry(\.invitationCode)
@KeyEntry(\.organization)
@KeyEntry(\.receivesAppointmentReminders)
@KeyEntry(\.receivesInactivityReminders)
@KeyEntry(\.receivesMedicationUpdates)
@KeyEntry(\.receivesQuestionnaireReminders)
@KeyEntry(\.receivesRecommendationUpdates)
@KeyEntry(\.receivesVitalsReminders)
@KeyEntry(\.receivesWeightAlerts)
extension AccountKeys {}
