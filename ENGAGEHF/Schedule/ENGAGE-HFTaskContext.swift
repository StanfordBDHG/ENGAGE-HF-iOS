//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ModelsR4


/// The context attached to each task in the ENGAGEHF.
///
/// We currently only support `Questionnaire`s, more cases can be added in the future.
enum ENGAGEHFTaskContext: Codable, Identifiable {
    /// The task should display a `Questionnaire`.
    case questionnaire(Questionnaire)
    /// The task is used for UI testing.
    case test(String)
    
    
    var id: FHIRPrimitive<FHIRString>? {
        switch self {
        case let .questionnaire(questionnaire):
            return questionnaire.id
        case .test:
            return FHIRPrimitive(FHIRString(UUID().uuidString))
        }
    }
    
    var actionType: LocalizedStringResource {
        switch self {
        case .questionnaire:
            return LocalizedStringResource("TASK_CONTEXT_ACTION_QUESTIONNAIRE")
        case .test:
            return LocalizedStringResource("TASK_CONTEXT_ACTION_TEST")
        }
    }
}
