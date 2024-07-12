//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


enum VitalsUnit: CustomStringConvertible {
    case mmHg
    case lb
    case kg
    case bpm
    
    
    var description: String {
        switch self {
        case .lb: "lb"
        case .kg: "kg"
        case .mmHg: "mmHg"
        case .bpm: "BPM"
        }
    }
    
    var hkUnitString: String {
        switch self {
        case .lb: "lb"
        case .kg: "kg"
        case .mmHg: "mmHg"
        case .bpm: "count/min"
        }
    }
}
