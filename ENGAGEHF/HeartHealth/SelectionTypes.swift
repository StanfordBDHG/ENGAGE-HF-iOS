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
}


/// The type of health data to be displayed as the main content of Heart Health view, after selecting .bloodPressure, .weight, or .heartRate
enum VitalsType: CustomStringConvertible {
    case weight
    case heartRate
    case bloodPressure
    
    
    /// The full name of the vital, displayed in the Description Header and Graph Legend
    var description: String {
        switch self {
        case .weight: "Body Weight"
        case .heartRate: "Heart Rate"
        case .bloodPressure: "Blood Pressure"
        }
    }
    
    /// The name of the LocalizedStringKey which maps to the localized description of the vitals type
    var explanationKey: String {
        switch self {
        case .weight: "vitalsWeight"
        case .heartRate: "vitalsHeartRate"
        case .bloodPressure: "vitalsBloodPressure"
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
    
    /// The unit corresponding to each vitlas type
    var unit: VitalsUnit {
        switch self {
        case .weight: Locale.current.measurementSystem == .us ? .lb : .kg
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
        case .overall: "Overall"
        case .physical: "Physical Limits"
        case .social: "Social Limits"
        case .quality: "Quality of Life"
        case .specific: "Specific Symptoms"
        case .dizziness: "Dizziness"
        }
    }
    
    /// The name of the LocalizedStringKey which maps to the localized description of the symptoms score
    var explanationKey: String {
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


enum DisplayDateResolution: CaseIterable, Identifiable, CustomStringConvertible {
    case daily
    case weekly
    case monthly
    
    var id: Self { self }
    
    var description: String {
        switch self {
        case .daily: "Daily"
        case .weekly: "Weekly"
        case .monthly: "Monthly"
        }
    }
    
    var intervalComponent: Calendar.Component {
        switch self {
        case .daily: .day
        case .weekly: .weekOfYear
        case .monthly: .month
        }
    }
}
