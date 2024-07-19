//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// A collection of known vitals types that may be encountered while plotting data using VtalsGraph
/// Note: Currently, HKSampleGraph.ViewModel uses the HKQuantityTypeIdentifier for bodyWeight and heartRate instead
enum KnownSeries: String {
    case symptomScore = "Symptom Score"
    case bodyWeight = "Body Weight"
    case heartRate = "Heart Rate"
    case bloodPressureSystolic = "Systolic"
    case bloodPressureDiastolic = "Diastolic"
}
