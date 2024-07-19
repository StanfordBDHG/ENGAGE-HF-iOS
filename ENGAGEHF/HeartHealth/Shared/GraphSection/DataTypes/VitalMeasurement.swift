//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// A representation of a measurement passed to VitalsGraph
/// Converted to an AggregatedMeasurement before plotting
struct VitalMeasurement: Hashable, Identifiable {
    let id: Self { self }
    let date: Date
    let value: Double
    let type: String
}
