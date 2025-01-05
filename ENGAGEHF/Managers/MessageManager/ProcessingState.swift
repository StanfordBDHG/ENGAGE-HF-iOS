//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation

struct ProcessingState: Equatable {
    let startTime: Date // TODO: remove contents order violation
    let type: ProcessingType
    let correlationId: String
    
    enum ProcessingType: Equatable {
        case healthMeasurement(samples: Int)
        case questionnaire(id: String)
        
        var localizedDescription: String {
            switch self {
            case .healthMeasurement(let count):
                return "\(count) health measurement\(count == 1 ? "" : "s")"
            case .questionnaire:
                return "questionnaire response"
            }
        }
    }
    
    var isStillProcessing: Bool {
        Date().timeIntervalSince(startTime) < 60
    }
}
