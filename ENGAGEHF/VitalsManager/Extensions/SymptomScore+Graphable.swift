//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


extension SymptomScore: Graphable {
    public func getDoubleValues(for symtomString: String) -> [Double] {
        guard let symptomType = SymptomsType(rawValue: symtomString) else {
            return []
        }
        
        return [self[keyPath: symptomType.symptomScoreKeyMap]]
    }
}
