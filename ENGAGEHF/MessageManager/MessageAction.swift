//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import Foundation


enum MessageAction: Equatable, CustomStringConvertible {
    case playVideo(sectionId: String, videoId: String)
    case showMedications
    case completeQuestionnaire(questionnaireId: String)
    case showHealthSummary
    case showHeartHealth(vitalsType: GraphSelection)
    case unknown
    
    
    var description: String {
        switch self {
        case .playVideo: "Play video"
        case .showMedications: "See medications"
        case .completeQuestionnaire: "See questionnaire"
        case .showHealthSummary: "See health summary"
        case .showHeartHealth: "See heart health"
        case .unknown: "No action"
        }
    }
}


extension MessageAction {
    var encodingString: String? {
        switch self {
        case .playVideo(let sectionId, let videoId): "videoSections/\(sectionId)/\(videoId)"
        case .showMedications: "medications"
        case .completeQuestionnaire(let questionnaireId): "questionnaires/\(questionnaireId)"
        case .showHealthSummary: "healthSummary"
        case .showHeartHealth(let vitalsType): vitalsType.collectionReference?.collectionID
        case .unknown: nil
        }
    }
    
    
    init(from actionString: String?) throws {
        guard let actionString else {
            self = .unknown
            return
        }
        
        let videoRegex = /^videoSections\/(?<sectionId>\w+)\/videos\/(?<videoId>\w+)$/
        let questionnaireRegex = /^questionnaires\/(?<questionnaireId>\w+)$/
        let heartHealthCollectionRefs = (try? Firestore.heartHealthCollectionReferences) ?? []
        
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
        case let heartHealthCollectionID where heartHealthCollectionRefs.map(\.collectionID).contains(heartHealthCollectionID):
            let matchingReference = heartHealthCollectionRefs.first(where: { $0.collectionID == heartHealthCollectionID })
            
            guard let vitalsType = try? GraphSelection(collectionRef: matchingReference) else {
                self = .unknown
                return
            }
            self = .showHeartHealth(vitalsType: vitalsType)
        default:
            self = .unknown
        }
    }
}
