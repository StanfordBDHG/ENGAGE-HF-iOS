//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit


enum VitalsUnit: CustomStringConvertible {
    case mmHg
    case lbs
    case kgs
    case bpm
    
    
    var description: String {
        switch self {
        case .lbs: "lb"
        case .kgs: "kg"
        case .mmHg: "mmHg"
        case .bpm: "BPM"
        }
    }
    
    var hkUnitString: String {
        switch self {
        case .lbs: "lb"
        case .kgs: "kg"
        case .mmHg: "mmHg"
        case .bpm: "count/min"
        }
    }
}
