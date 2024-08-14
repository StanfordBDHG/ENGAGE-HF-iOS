//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ModelsR4


protocol ObservationValueProtocol {
    var observationValue: ValueXProtocol? { get }
}


extension Observation: ObservationValueProtocol {
    var observationValue: ValueXProtocol? {
        self.value
    }
}


extension ObservationComponent: ObservationValueProtocol {
    var observationValue: ValueXProtocol? {
        self.value
    }
}
