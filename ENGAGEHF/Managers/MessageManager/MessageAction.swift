//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import Foundation


enum MessageAction: Equatable {
    case playVideo(sectionId: String, videoId: String)
    case showMedications
    case completeQuestionnaire(questionnaireId: String)
    case showHealthSummary
    case showHeartHealth
    case unknown
}


extension MessageAction {
    var localizedDescription: LocalizedStringResource {
        switch self {
        case .playVideo: LocalizedStringResource("Play Video")
        case .showMedications: LocalizedStringResource("See Medications")
        case .completeQuestionnaire: LocalizedStringResource("Start Questionnaire")
        case .showHealthSummary: LocalizedStringResource("See Health Summary")
        case .showHeartHealth: LocalizedStringResource("See Heart Health")
        case .unknown: LocalizedStringResource("")
        }
    }
}


extension MessageAction {
    var encodingString: String? {
        switch self {
        case let .playVideo(sectionId, videoId): "videoSections/\(sectionId)/\(videoId)"
        case .showMedications: "medications"
        case .completeQuestionnaire(let questionnaireId): "questionnaires/\(questionnaireId)"
        case .showHealthSummary: "healthSummary"
        case .showHeartHealth: "observations"
        case .unknown: nil
        }
    }
    
    
    init(from actionString: String?) {
        guard let actionString else {
            self = .unknown
            return
        }
        
        let videoRegex = /^videoSections\/(?<sectionId>\w+)\/videos\/(?<videoId>\w+)$/
        let questionnaireRegex = /^questionnaires\/(?<questionnaireId>\w+)$/
        
        switch actionString {
        case let videoInfoString where videoInfoString.contains(videoRegex):
            guard let videoInfo = videoInfoString.firstMatch(of: videoRegex)?.output else {
                self = .unknown
                return
            }
            self = .playVideo(sectionId: String(videoInfo.sectionId), videoId: String(videoInfo.videoId))
        case let questionnaireInfoString where questionnaireInfoString.contains(questionnaireRegex):
            guard let questionnaireInfo = questionnaireInfoString.firstMatch(of: questionnaireRegex)?.output else {
                self = .unknown
                return
            }
            self = .completeQuestionnaire(questionnaireId: String(questionnaireInfo.questionnaireId))
        case "medications":
            self = .showMedications
        case "healthSummary":
            self = .showHealthSummary
        case "observations":
            self = .showHeartHealth
        default:
            self = .unknown
        }
    }
}
