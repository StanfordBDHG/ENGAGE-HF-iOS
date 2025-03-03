//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation

struct ProcessingState: Equatable {
    enum ProcessingType: Equatable {
        case healthMeasurement(samples: Int)
        case questionnaire(id: String)
        
        var localizedDescription: String {
            switch self {
            case .healthMeasurement(let count):
                let measurementString = String(localized: "measurement", comment: "Single measurement in processing state")
                let measurementsString = String(localized: "measurements", comment: "Multiple measurements in processing state")
                let countString = count == 1 ? measurementString : measurementsString
                return String(localized: "Processing \(count) \(countString)...", comment: "Processing state for health measurements")
            case .questionnaire:
                return String(localized: "Processing questionnaire...", comment: "Processing state for questionnaire")
            }
        }
    }
    
    let startTime: Date
    let type: ProcessingType
    
    var isStillProcessing: Bool {
        Date.now.timeIntervalSince(startTime) < 60
    }
}
