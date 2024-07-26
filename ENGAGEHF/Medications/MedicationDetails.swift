//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import Foundation


enum MedicationRecommendationType: String, Codable, Comparable {
    case targetDoseReached
    case personalTargetDoseReached
    case improvementAvailable
    case morePatientObservationsRequired
    case moreLabObservationsRequired
    case notStarted
    case noActionRequired
    
    
    private var priority: Int {
        switch self {
        case .targetDoseReached: 3
        case .personalTargetDoseReached:  4
        case .improvementAvailable:  7
        case .morePatientObservationsRequired: 6
        case .moreLabObservationsRequired: 5
        case .notStarted: 2
        case .noActionRequired: 1
        }
    }
    
    static func < (lhs: MedicationRecommendationType, rhs: MedicationRecommendationType) -> Bool {
        lhs.priority < rhs.priority
    }
    
    static func == (lhs: MedicationRecommendationType, rhs: MedicationRecommendationType) -> Bool {
        lhs.priority == rhs.priority
    }
}


/// A description of the medication's dose, for now in units 'unit/day'
struct Dose: Hashable, Codable {
    let current: Double
    let minimum: Double
    let target: Double
}


/// A collection containing all of the doses associated with the patient's medication
struct DosageInformation: Codable {
    let doses: [Dose]
    let unit: String
}


/// A medication that the patient is either currently taking or which is recommended for the patient to start
struct MedicationDetails: Identifiable, Codable, Comparable {
    @DocumentID var id: String?
    
    let title: String
    let subtitle: String
    let description: String
    let type: MedicationRecommendationType
    let dosageInformation: DosageInformation?
    
    
    static func < (lhs: MedicationDetails, rhs: MedicationDetails) -> Bool {
        lhs.type < rhs.type
    }
    
    static func == (lhs: MedicationDetails, rhs: MedicationDetails) -> Bool {
        lhs.type == rhs.type
    }
}
