//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FHIRQuestionnaires
import FirebaseFirestore
import SpeziQuestionnaire
import SpeziViews
import SwiftUI


struct QuestionnaireSheetView: View {
    private let questionnaireId: String
    
    @State private var questionnaire: Questionnaire?
    @State private var viewState: ViewState = .idle
    
    @Environment(ENGAGEHFStandard.self) private var standard
    @Environment(\.dismiss) private var dismiss
    
    
    var body: some View {
        ZStack {
            if let questionnaire {
                QuestionnaireView(questionnaire: questionnaire) { result in
                    guard case let .completed(questionnaireResponse) = result else {
                        // user cancelled
                        dismiss()
                        return
                    }
                    
                    do {
                        try await standard.add(response: questionnaireResponse)
                        dismiss()
                    } catch {
                        viewState = .error(AnyLocalizedError(error: error))
                    }
                }
            } else {
                ProgressView("Questionnaire Loading")
                    .background(Color(.systemGroupedBackground))
            }
        }
            .task {
                do {
#if DEBUG || TEST
                    if FeatureFlags.setupTestMessages {
                        questionnaire = .formExample
                        return
                    }
#endif
                    questionnaire = try await Firestore.questionnairesCollectionReference
                        .document(questionnaireId)
                        .getDocument(as: Questionnaire.self)
                } catch {
                    viewState = .error(AnyLocalizedError(error: error, defaultErrorDescription: String(localized: "Unable to load questionnaire.")))
                }
            }
            .viewStateAlert(state: $viewState)
    }
    
    
    init(questionnaireId: String) {
        self.questionnaireId = questionnaireId
    }
}


#Preview {
    QuestionnaireSheetView(questionnaireId: "0")
}
