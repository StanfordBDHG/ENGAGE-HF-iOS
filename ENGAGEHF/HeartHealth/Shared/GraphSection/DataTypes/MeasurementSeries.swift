//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// A container for representing an aggregated data series
struct MeasurementSeries: Identifiable {
    let id = UUID()
    let seriesName: String
    let data: [AggregatedMeasurement]
    let average: Double
}
