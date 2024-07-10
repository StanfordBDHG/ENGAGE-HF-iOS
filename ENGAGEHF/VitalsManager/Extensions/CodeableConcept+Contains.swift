//
//  CodeableConcept+Contains.swift
//  ENGAGEHF
//
//  Created by Nick Riedman on 7/9/24.
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
