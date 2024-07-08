//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import Foundation


/// The score represnting the result of a patient's response to a KCCQ survey
/// Parameters are specified in compliance with:
/// https://github.com/StanfordBDHG/ENGAGE-HF-Firebase/tree/web-data-scheme
public struct SymptomScore: Identifiable, Equatable, Codable {
    @DocumentID public var id: String?
    public var date: Date
    public var overallScore: Double
    public var physicalLimitsScore: Double
    public var socialLimitsScore: Double
    public var qualityOfLifeScore: Double
    public var specificSymptomsScore: Double
    public var dizzinessScore: Double
}
