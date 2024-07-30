//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct VideoSection: View {
    let collection: VideoCollection
    
    
    var body: some View {
        Section(
            content: {
                ForEach(collection.videos.sorted(by: { $0.orderIndex < $1.orderIndex })) { video in
                    Text("DocId: \(video.id ?? "nil")")
                    Text("Title: " + video.title)
                    Text("YouTube Id: " + video.youtubeId)
                    Text("OrderIndex: \(video.orderIndex)")
                }
            },
            header: {
                Text("\(collection.title), \(collection.orderIndex), \(collection.id ?? "nil")")
            }
        )
    }
}


#if DEBUG
#Preview {
    VideoSection(
        collection: VideoCollection(
            context: VideoCollectionContext(
                title: "Section 1",
                description: "Localized description of section 1.",
                orderIndex: 1
            ),
            videos: [Video(title: "Video 1", youtubeId: "1234", orderIndex: 1)]
        )
    )
}
#endif
