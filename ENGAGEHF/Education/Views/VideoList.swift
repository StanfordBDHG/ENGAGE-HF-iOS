//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct VideoList: View {
    let videoCollections: [VideoCollection]
    
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(videoCollections.sorted(by: { $0.orderIndex < $1.orderIndex })) { videoCollection in
                    VideoListSection(
                        title: videoCollection.title,
                        subtitle: videoCollection.description,
                        videos: videoCollection.videos
                    )
                }
            }
            .padding()
        }
    }
}


#if DEBUG
#Preview {
    VideoList(
        videoCollections: [
            VideoCollection(
                context: VideoCollectionContext(
                    title: "ENGAGE-HF Application",
                    description: "Helpful videos on the ENGAGE-HF mobile application.",
                    orderIndex: 1
                ),
                videos: [Video(title: "Welcome Video", youtubeId: "y2ziZVWossE", orderIndex: 1)]
            )
        ]
    )
}
#endif
