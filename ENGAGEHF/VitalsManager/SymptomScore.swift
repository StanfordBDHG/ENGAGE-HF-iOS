//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import Foundation


/// The score representing the result of a patient's response to a KCCQ survey
/// Parameters are specified in compliance with:
/// https://github.com/StanfordBDHG/ENGAGE-HF-Firebase/tree/web-data-scheme
public struct SymptomScore: Identifiable, Equatable {
    @DocumentID public var id: String?
    public let date: Date
    public let overallScore: Double?
    public let physicalLimitsScore: Double?
    public let socialLimitsScore: Double?
    public let qualityOfLifeScore: Double?
    public let symptomFrequencyScore: Double?
    public let dizzinessScore: Double?
}


extension SymptomScore: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self._id = try container.decode(DocumentID<String>.self, forKey: .id)
        
        self.date = try container.decodeISO8601Date(forKey: .date)
        self.overallScore = try container.decodeIfPresent(Double.self, forKey: .overallScore)
        self.physicalLimitsScore = try container.decodeIfPresent(Double.self, forKey: .physicalLimitsScore)
        self.socialLimitsScore = try container.decodeIfPresent(Double.self, forKey: .socialLimitsScore)
        self.qualityOfLifeScore = try container.decodeIfPresent(Double.self, forKey: .qualityOfLifeScore)
        self.symptomFrequencyScore = try container.decodeIfPresent(Double.self, forKey: .symptomFrequencyScore)
        self.dizzinessScore = try container.decodeIfPresent(Double.self, forKey: .dizzinessScore)
    }
}
