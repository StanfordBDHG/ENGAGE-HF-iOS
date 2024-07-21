//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import class ModelsR4.CodeableConcept


extension CodeableConcept {
    func containsCoding(code: String, system: URL) -> Bool {
        coding?.contains {
            $0.code?.value?.string == code && $0.system?.value?.url == system
        } ?? false
    }
}
