//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// A medication that the patient is either currently taking or which is recommended for the patient to start
/// For recommendations, only the displayName will be present
/// For current medications, all fields may be present
struct Medication: Identifiable {
    let id = UUID()
    
    let displayName: String? = nil
    let localizedDescription: String? = nil
    let currentDailyDosage: [Double]? = nil
    let minimumDailyDosage: [Double]? = nil
    let targetDailyDosage: [Double]? = nil
}
