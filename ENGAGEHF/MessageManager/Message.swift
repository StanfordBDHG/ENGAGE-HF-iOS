//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import Foundation


enum MessageAction {
    case playVideo(videoInfo: (sectionId: String, videoId: String))
    case showMedications
    case completeQuestionnaire(questionnaireId: String)
    case showHealthSummary
    case showHeartHealth(vitalsType: GraphSelection)
    case unknown
    
    
    init(rawValue: String?) {
        guard let rawValue else {
            self = .unknown
            return
        }
        
        let videoRegex = /^videoSection\/(?<sectionId>\w+)\/(?<videoId>\w+)$/
        let questionnaireRegex = /^questionnaires\/(?<questionnaireId>\w+)$/
        
        // Switch statements do not work for matching rawValue to the various regexes,
        // so iterate all cases manually
        if let videoMatch = rawValue.firstMatch(of: videoRegex)?.output {
            self = .playVideo(videoInfo: (videoMatch.sectionId.base, videoMatch.videoId.base))
            return
        }
        
        if let questionnaireMatch = rawValue.firstMatch(of: questionnaireRegex)?.output {
            self = .completeQuestionnaire(questionnaireId: questionnaireMatch.questionnaireId.base)
            return
        }
        
    }
}


/// A message describing recent changes to the user's data or calls-to-action for the patient to complete
/// Data structure as defined in: https://github.com/StanfordBDHG/ENGAGE-HF-Firebase
struct Message: Identifiable, Equatable {
    @DocumentID var id: String?
    
    let title: String
    let description: String?
    let action: MessageAction?
    let isDismissible: Bool
    let dueDate: Date?
    let completionDate: Date?
    
    
    init(
        title: String,
        description: String?,
        action: String?,
        isDismissible: Bool,
        dueDate: Date?,
        completionDate: Date?,
        id: String? = UUID().uuidString
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.action = action
        self.isDismissible = isDismissible
        self.dueDate = dueDate
        self.completionDate = completionDate
    }
}


extension Message: Codable {
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
        self.action = try container.decodeIfPresent(String.self, forKey: .action)
        self.isDismissible = try container.decode(Bool.self, forKey: .isDismissible)
        self.dueDate = try container.decodeIfPresent(Date.self, forKey: .dueDate)
        self.completionDate = try container.decodeIfPresent(Date.self, forKey: .completionDate)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .docId)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(action, forKey: .action)
        try container.encode(isDismissible, forKey: .isDismissible)
        try container.encodeIfPresent(dueDate, forKey: .dueDate)
        try container.encodeIfPresent(completionDate, forKey: .completionDate)
    }
}
