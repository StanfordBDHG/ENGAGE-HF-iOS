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
struct SymptomScore: Identifiable, Equatable, Codable {
    @DocumentID var id: String?
    var date: Date
    var overallScore: Double
    var physicalLimitsScore: Double
    var socialLimitsScore: Double
    var qualityOfLifeScore: Double
    var specificSymptomsScore: Double
    var dizzinessScore: Double
}
