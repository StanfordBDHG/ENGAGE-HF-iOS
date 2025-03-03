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
    // MARK: - Type Properties
    
    // MARK: - Properties
    @Environment(ENGAGEHFStandard.self) private var standard
    @Environment(\.dismiss) private var dismiss
    
    @State private var questionnaire: Questionnaire?
    @State private var viewState: ViewState = .idle
    
    private let questionnaireId: String
    
    // MARK: - View
    var body: some View {
        ZStack {
            if let questionnaire {
                QuestionnaireView(questionnaire: questionnaire) { result in
                    guard case let .completed(questionnaireResponse) = result else {
                        // user cancelled
                        dismiss()
                        return
                    }
                    
#if DEBUG
                    if ProcessInfo.processInfo.isPreviewSimulator {
                        dismiss()
                        return
                    }
#endif
                    
                    Task {
                        do {
                            try await standard.add(response: questionnaireResponse)
                            try? await Task.sleep(for: .seconds(1))
                            dismiss()
                        } catch {
                            viewState = .error(AnyLocalizedError(error: error))
                        }
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
                    if ProcessInfo.processInfo.isPreviewSimulator || FeatureFlags.setupTestMessages {
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
    struct QuestionnaireSheetViewPreviewWrapper: View {
        @State private var questionnaireId: String?
        
        
        var body: some View {
            Button("Tap Here") {
                questionnaireId = "0"
            }
                .buttonStyle(.borderedProminent)
                .sheet(item: $questionnaireId) { questionnaireId in
                    QuestionnaireSheetView(questionnaireId: questionnaireId)
                }
        }
    }
    
    return QuestionnaireSheetViewPreviewWrapper()
        .previewWith(standard: ENGAGEHFStandard()) {}
}
