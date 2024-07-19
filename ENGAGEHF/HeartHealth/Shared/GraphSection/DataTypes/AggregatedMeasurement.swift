//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// A graph-ready representation of a vitals measurement
/// Represents a single, aggregated (averaged across an interval) data point
struct AggregatedMeasurement: Hashable, Identifiable {
    var id: Self { self }
    var date: Date
    var value: Double
    var count: Int
    var series: String
}
