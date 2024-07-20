//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit


/// The type of Vitals to be displayed as the main content of the Heart Health view
/// Chosen by GraphPicker in HeartHealth
enum GraphSelection: CaseIterable, Identifiable, CustomStringConvertible {
    case symptoms
    case weight
    case heartRate
    case bloodPressure
    
    var id: Self { self }
    
    var description: String {
        switch self {
        case .symptoms: "Symptoms"
        case .weight: "Weight"
        case .heartRate: "HR"
        case .bloodPressure: "BP"
        }
    }
    
    var localizedEmptyHistoryWarning: String {
        switch self {
        case .symptoms: String(localized: "symptomsMissing")
        case .weight: String(localized: "weightMissing")
        case .heartRate: String(localized: "heartRateMissing")
        case .bloodPressure: String(localized: "bloodPressureMissing")
        }
    }
}


/// The type of health data to be displayed as the main content of Heart Health view, after selecting .bloodPressure, .weight, or .heartRate
enum VitalsType: CustomStringConvertible {
    case weight
    case heartRate
    case bloodPressure
    
    
    var description: String {
        switch self {
        case .weight: "Body Weight"
        case .heartRate: "Heart Rate"
        case .bloodPressure: "Blood Pressure"
        }
    }
    
    /// The localized description of the vitals type
    var localizedExplanation: String {
        switch self {
        case .weight: String(localized: "vitalsWeight")
        case .heartRate: String(localized: "vitalsHeartRate")
        case .bloodPressure: String(localized: "vitalsBloodPressure")
        }
    }
    
    /// The corresponding GraphSelection associted with each VitalsType
    var graphType: GraphSelection {
        switch self {
        case .weight: .weight
        case .heartRate: .heartRate
        case .bloodPressure: .bloodPressure
        }
    }
    
    /// The HKUnit corresponding to each vitals type
    var unit: VitalsUnit {
        switch self {
        case .weight: Locale.current.measurementSystem == .us ? .lbs : .kgs
        case .heartRate: .bpm
        case .bloodPressure: .mmHg
        }
    }
}


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
    var symptomScoreKeyMap: KeyPath<SymptomScore, Double> {
        switch self {
        case .overall: \.overallScore
        case .physical: \.physicalLimitsScore
        case .social: \.socialLimitsScore
        case .quality: \.qualityOfLifeScore
        case .specific: \.specificSymptomsScore
        case .dizziness: \.dizzinessScore
        }
    }
}
