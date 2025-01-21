//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit


/// A collection of known vitals types that may be encountered while plotting data using VitalsGraph
/// Note: Currently, HKSampleGraph.ViewModel uses the HKQuantityTypeIdentifier for bodyWeight and heartRate instead
enum KnownVitalsSeries: Equatable {
    case symptomScore
    case bodyWeight
    case heartRate
    case bloodPressureSystolic
    case bloodPressureDiastolic
    
    
    var localizedDescription: LocalizedStringResource {
        switch self {
        case .symptomScore:
            LocalizedStringResource("Symptom Score")
        case .bodyWeight:
            LocalizedStringResource("Body Weight")
        case .heartRate:
            LocalizedStringResource("Heart Rate")
        case .bloodPressureSystolic:
            LocalizedStringResource("Systolic")
        case .bloodPressureDiastolic:
            LocalizedStringResource("Diastolic")
        }
    }
}


extension KnownVitalsSeries {
    init?(matching hkId: String) {
        let match: Self? = switch hkId {
        case HKQuantityTypeIdentifier.heartRate.rawValue: .heartRate
        case HKQuantityTypeIdentifier.bodyMass.rawValue: .bodyWeight
        case HKQuantityTypeIdentifier.bloodPressureSystolic.rawValue: .bloodPressureSystolic
        case HKQuantityTypeIdentifier.bloodPressureDiastolic.rawValue: .bloodPressureDiastolic
        // Recognize the HKCorrelationTypeIdentifier for blood pressure, and in this case just return systolic
        case HKCorrelationTypeIdentifier.bloodPressure.rawValue: .bloodPressureSystolic
        default: nil
        }
        
        guard let match else {
            return nil
        }
        
        self = match
    }
}
