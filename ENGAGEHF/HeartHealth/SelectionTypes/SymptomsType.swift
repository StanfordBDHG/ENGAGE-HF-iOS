//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import Foundation
import HealthKit


/// The subfield of Symptom Score to be displayed as the main content of Heart Health view when GraphSelection is .symptom
/// Chosen by the SymptomPicker in SymptomContentView
enum SymptomsType: String, CaseIterable, Identifiable, CustomStringConvertible, Equatable {
    case overall
    case physical
    case social
    case quality
    case specific
    case dizziness
    
    var id: Self { self }
    
    
    /// The name displayed in the Picker UI element for selecting the symptom type to be shown
    var description: String {
        switch self {
        case .overall: "Overall"
        case .physical: "Physical"
        case .social: "Social"
        case .quality: "Quality"
        case .specific: "Specific"
        case .dizziness: "Dizziness"
        }
    }
    
    
    /// The full name of the score, displayed in the Description Header
    var fullName: String {
        switch self {
        case .overall: "Overall Score"
        case .physical: "Physical Limits Score"
        case .social: "Social Limits Score"
        case .quality: "Quality of Life Score"
        case .specific: "Specific Symptoms Score"
        case .dizziness: "Dizziness Score"
        }
    }
    
    var localizedEmptyHistoryWarning: String {
        GraphSelection.symptoms.localizedEmptyHistoryWarning
    }
    
    /// The localized description of the symptoms score
    var localizedExplanation: String {
        switch self {
        case .overall: String(localized: "symptomOverall")
        case .physical: String(localized: "symptomPhysical")
        case .social: String(localized: "symptomSocial")
        case .quality: String(localized: "symptomQuality")
        case .specific: String(localized: "symptomSpecific")
        case .dizziness: String(localized: "symptomDizziness")
        }
    }
    
    /// The path to access the parameter in SymptomScore that corresponds to the Type described by an instance of this enum
    var symptomScoreKeyMap: KeyPath<SymptomScore, Double?> {
        switch self {
        case .overall: \.overallScore
        case .physical: \.physicalLimitsScore
        case .social: \.socialLimitsScore
        case .quality: \.qualityOfLifeScore
        case .specific: \.symptomFrequencyScore
        case .dizziness: \.dizzinessScore
        }
    }
}
