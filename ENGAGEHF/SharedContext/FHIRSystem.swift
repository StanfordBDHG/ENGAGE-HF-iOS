//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


enum FHIRSystem {
    case loinc
    
    
    var url: URL {
        switch self {
        case .loinc: URL(string: "http://loinc.org")!
        }
    }
}
