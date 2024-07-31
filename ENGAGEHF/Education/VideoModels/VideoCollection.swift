//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import Foundation


struct VideoCollection: Identifiable {
    var id: String?
    
    let title: String
    let description: String
    let orderIndex: Int
    let videos: [Video]
    
    
    init(context: VideoCollectionContext, videos: [Video]) {
        self.id = context.id
        self.title = context.title
        self.description = context.description
        self.orderIndex = context.orderIndex
        self.videos = videos
    }
}
