//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import Foundation


enum MedicationRecommendationType: String, Codable {
    case targetDoseReached
    case personalTargetDoseReached
    case improvementAvailable
    case morePatientObservationsRequired
    case moreLabObservationsRequired
    case notStarted
    case noActionRequired
}


/// A description of the medication's dose, for now in units 'unit/day'
struct Dose: Codable {
    let current: Double
    let minimum: Double
    let target: Double
    let unit: String
}


/// A medication that the patient is either currently taking or which is recommended for the patient to start
struct MedicationDetails: Identifiable, Codable {
    @DocumentID var id: String?
    
    let title: String
    let subtitle: String
    let description: String
    let type: MedicationRecommendationType
    let doses: [Dose]
}
