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
public struct SymptomScore: Identifiable, Equatable, Codable {
    @DocumentID public var id: String?
    public let date: Date
    public let overallScore: Double
    public let physicalLimitsScore: Double
    public let socialLimitsScore: Double
    public let qualityOfLifeScore: Double
    public let specificSymptomsScore: Double
    public let dizzinessScore: Double
}
