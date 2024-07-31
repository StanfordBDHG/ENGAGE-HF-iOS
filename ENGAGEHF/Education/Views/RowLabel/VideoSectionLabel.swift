//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct VideoSectionLabel: View {
    let videoCollection: VideoCollection
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(videoCollection.title)
                .font(.headline)
            Text(videoCollection.description)
                .font(.subheadline)
        }
    }
}


#if DEBUG
#Preview {
    VideoSectionLabel(
        videoCollection: VideoCollection(
            context: VideoCollectionContext(
                title: "ENGAGE-HF Application",
                description: "Helpful videos on the ENGAGE-HF mobile application.",
                orderIndex: 1
            ),
            videos: [Video(title: "Welcome Video", youtubeId: "y2ziZVWossE", orderIndex: 1)]
        )
    )
}
#endif
