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
        if videoCollections.isEmpty {
            ContentUnavailableView(
                "No Videos",
                systemImage: "video.slash",
                description: Text("There are currently no videos in any collection.")
            )
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(videoCollections.sorted(by: { $0.orderIndex < $1.orderIndex })) { videoCollection in
                        StudyApplicationListCard {
                            VideoListSection(
                                title: videoCollection.title,
                                subtitle: videoCollection.description,
                                videos: videoCollection.videos
                            )
                        }
                        .accessibilityIdentifier("Video Section: \(videoCollection.title)")
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
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
    .previewWith(standard: ENGAGEHFStandard()) {
        NavigationManager()
    }
}
#endif
