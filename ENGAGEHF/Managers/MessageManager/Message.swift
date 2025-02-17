//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import Foundation


/// A message describing recent changes to the user's data or calls-to-action for the patient to complete
/// Data structure as defined in: https://github.com/StanfordBDHG/ENGAGE-HF-Firebase
struct Message: Identifiable, Equatable {
    @DocumentID var id: String?
    
    let title: String
    let description: String?
    let action: MessageAction
    let isDismissible: Bool
    // periphery:ignore - Currently not used in the app but a complete representation of the model.
    let dueDate: Date?
    // periphery:ignore - Currently not used in the app but a complete representation of the model.
    let completionDate: Date?
    var processingState: ProcessingState?
    
    var isProcessing: Bool {
        processingState?.isStillProcessing ?? false
    }
    
    func isRelatedTo(_ state: ProcessingState) -> Bool {
        switch (self.action, state.type) {
        case (.showHeartHealth, .healthMeasurement):
            return true
        case (.completeQuestionnaire(let questionnaireId), .questionnaire(let id)):
            return questionnaireId == id
        default:
            return false
        }
    }
    
    init(
        title: String,
        description: String?,
        action: MessageAction,
        isDismissible: Bool,
        dueDate: Date?,
        completionDate: Date?,
        id: String? = UUID().uuidString,
        processingState: ProcessingState? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.action = action
        self.isDismissible = isDismissible
        self.dueDate = dueDate
        self.completionDate = completionDate
        self.processingState = processingState
    }
}


extension Message: Decodable {
    private enum CodingKeys: CodingKey {
        case title
        case description
        case action
        case isDismissible
        case dueDate
        case completionDate
        case docId
    }
    
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self._id = try container.decode(DocumentID<String>.self, forKey: .docId)
        self.title = try container.decodeLocalizedString(forKey: .title)
        self.description = try container.decodeLocalizedStringIfPresent(forKey: .description)
        self.action = try MessageAction(from: container.decodeIfPresent(String.self, forKey: .action))
        self.isDismissible = try container.decode(Bool.self, forKey: .isDismissible)
        self.dueDate = try container.decodeISO8601DateIfPresent(forKey: .dueDate)
        self.completionDate = try container.decodeISO8601DateIfPresent(forKey: .completionDate)
        self.processingState = nil  // Initialize as nil since it's not stored in Firebase
    }
}
