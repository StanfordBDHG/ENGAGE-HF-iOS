//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ModelsR4


//extension MedicationRequest {
//    /// Assuming the stored medication is a reference to a drug and structured as "medications/$medicationId$/drug/$drugId$",
//    /// returns a path to the medication structured as "medications/$medicationId$"
//    func extractMedicationPath() throws -> String {
//        guard case let .reference(medicationReference) = medication else {
//            throw MedicationsError.medicationReferenceIsCodeableConcept
//        }
//        
//        guard let drugPath = medicationReference.reference?.value?.string else {
//            throw MedicationsError.invalidMedicationReference
//        }
//        
//        // Assuming drugPath is of the form "medications/$medicationId$/drug/$drugId$"
//        // Relevant medication information is instead found at "medications/$medicationId$"
//        // For now, just split the path and take the tokens up to the token after "medications"
//        //
//        // For a more rigorous implementation, get the medicationId from the drug codeable concept,
//        // then loop back and access "medications/$medicationId$".
//        // However, at the moment we are unable to store medicationsId in the drug codeable concept
//        let pathComponents = drugPath.split(separator: "/")
//        guard let medicationsIndex = pathComponents.firstIndex(of: "medications"),
//              medicationsIndex + 1 <= drugPath.count else {
//            throw MedicationsError.invalidMedicationReference
//        }
//        
//        return pathComponents[...medicationsIndex].joined(separator: "/")
//    }
//}
