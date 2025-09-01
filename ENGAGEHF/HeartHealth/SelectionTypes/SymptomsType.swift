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
enum SymptomsType: String, CaseIterable, Identifiable, CustomLocalizedStringResourceConvertible, Equatable {
    case overall
    case physical
    case social
    case quality
    case specific
    case dizziness
    
    var id: Self { self }
    
    
    /// The name displayed in the Picker UI element for selecting the symptom type to be shown
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .overall: "Overall"
        case .physical: "Physical"
        case .social: "Social"
        case .quality: "Quality of Life"
        case .specific: "Symptoms"
        case .dizziness: "Dizziness"
        }
    }
    
    
    /// The full name of the score, displayed in the Description Header
    var localizedFullName: LocalizedStringResource {
        switch self {
        case .overall: "Overall Score"
        case .physical: "Physical Limits Score"
        case .social: "Social Limits Score"
        case .quality: "Quality of Life Score"
        case .specific: "Symptom Frequency Score"
        case .dizziness: "Dizziness Score"
        }
    }
    
    /// The localized description of the symptoms score
    var localizedExplanation: LocalizedStringResource {
        switch self {
        case .overall: "symptomOverall"
        case .physical: "symptomPhysical"
        case .social: "symptomSocial"
        case .quality: "symptomQuality"
        case .specific: "symptomSpecific"
        case .dizziness: "symptomDizziness"
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
