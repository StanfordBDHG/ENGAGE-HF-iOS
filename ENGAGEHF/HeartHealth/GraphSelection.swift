//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


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
    
    var fullName: String {
        switch self {
        case .symptoms: "Symptoms"
        case .weight: "Weight"
        case .heartRate: "Heart Rate"
        case .bloodPressure: "Blood Pressure"
        }
    }
    
    var explanation: String {
        switch self {
        case .symptoms: "symptomOverall"
        case .weight: "vitalsWeight"
        case .heartRate: "vitalsHeartRate"
        case .bloodPressure: "vitalsBloodPressure"
        }
    }
}
