//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import Foundation
import SwiftUI


enum MedicationRecommendationType: String, Decodable, Comparable {
    case targetDoseReached
    case personalTargetDoseReached
    case improvementAvailable
    case morePatientObservationsRequired
    case moreLabObservationsRequired
    case notStarted
    case noActionRequired
    
    
    var style: RecommendationStyle {
        switch self {
        case .targetDoseReached: .targetReached
        case .personalTargetDoseReached: .targetReached
        case .improvementAvailable: .improvementAvailable
        case .moreLabObservationsRequired: .actionRequired
        case .morePatientObservationsRequired: .actionRequired
        case .noActionRequired: .notStarted
        case .notStarted: .notStarted
        }
    }
    
    
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


/// A daily medication schedule. Includes current, minimum, and target schedules.
/// Example: 20.0 mg twice daily would have dose=20.0 and timesDaily=2.
struct DoseSchedule: Hashable, Decodable {
    let frequency: Double
    let quantity: [Double]
    
    
    var totalDailyIntake: Double { quantity.reduce(0, +) * frequency }
}


/// A collection containing details of a patients dose for a single medication.
/// Describes the dosage in terms of total medication across all ingredients.
struct DosageInformation: Decodable {
    let currentSchedule: [DoseSchedule]
    let targetSchedule: [DoseSchedule]
    let unit: String
    
    
    var currentDailyIntake: Double {
        self.currentSchedule.map(\.totalDailyIntake).reduce(0, +)
    }
    
    var targetDailyIntake: Double {
        self.targetSchedule.map(\.totalDailyIntake).reduce(0, +)
    }
}


/// Wrapper for decoding medication details from firestore.
struct MedicationDetailsWrapper: Decodable {
    @DocumentID private var id: String?
    
    private let displayInformation: MedicationDetails
    
    
    var medicationDetails: MedicationDetails {
        var copy = displayInformation
        copy.id = self.id
        return copy
    }
}


/// A medication that the patient is either currently taking or which is recommended for the patient to start.
struct MedicationDetails: Identifiable {
    var id: String?
    
    let title: String
    let subtitle: String
    let description: String
    let videoPath: String?
    let type: MedicationRecommendationType
    let dosageInformation: DosageInformation
}


extension MedicationDetails: Decodable {
    private enum CodingKeys: CodingKey {
        case title
        case subtitle
        case description
        case type
        case dosageInformation
        case videoPath
    }
    
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.title = try container.decodeLocalizedString(forKey: .title)
        self.subtitle = try container.decodeLocalizedString(forKey: .subtitle)
        self.description = try container.decodeLocalizedString(forKey: .description)
        self.videoPath = try container.decodeIfPresent(String.self, forKey: .videoPath)
        self.type = try container.decode(MedicationRecommendationType.self, forKey: .type)
        self.dosageInformation = try container.decode(DosageInformation.self, forKey: .dosageInformation)
    }
}
