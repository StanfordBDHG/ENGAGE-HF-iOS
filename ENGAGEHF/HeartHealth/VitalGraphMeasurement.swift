//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// A graph-ready representation of a measurement
/// For plotting SymptomScores and HKSamples in HKSampleGraph and SymptomsGraph
struct VitalGraphMeasurement: Hashable, Identifiable {
    var id: Self { self }
    var date: Date
    var value: Double
}
