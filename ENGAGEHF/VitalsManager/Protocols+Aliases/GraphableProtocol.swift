//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit


public protocol Graphable: Identifiable {
    var date: Date { get }
    
    func getDoubleValues(for unit: String) -> [Double]
}
