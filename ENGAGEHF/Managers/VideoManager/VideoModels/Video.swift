//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import Foundation


struct Video: Hashable, Identifiable, Decodable {
    private enum CodingKeys: CodingKey {
        case title
        case description
        case orderIndex
        case youtubeId
        case docId
    }
    
    
    @DocumentID var id: String?
    
    let title: String
    let description: String?
    let youtubeId: String
    let orderIndex: Int
    
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self._id = try container.decode(DocumentID<String>.self, forKey: .docId)
        
        self.title = try container.decodeLocalizedString(forKey: .title)
        self.description = try? container.decodeLocalizedString(forKey: .description)
        self.youtubeId = try container.decodeLocalizedString(forKey: .youtubeId)
        self.orderIndex = try container.decode(Int.self, forKey: .orderIndex)
    }
}


#if DEBUG || TEST
extension Video {
    init(
        title: String,
        youtubeId: String,
        orderIndex: Int,
        id: String? = UUID().uuidString,
        description: String? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.youtubeId = youtubeId
        self.orderIndex = orderIndex
    }
}
#endif
