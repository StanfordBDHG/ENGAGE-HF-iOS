//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct VideoView: View {
    let video: Video
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VideoPlayer(youtubeId: video.youtubeId)
                .padding(.top)
            Text(video.description ?? "Video Description")
                .padding()
            Spacer()
        }
            .navigationTitle(video.title)
            .navigationBarTitleDisplayMode(.inline)
    }
    
    
    init(_ video: Video) {
        self.video = video
    }
}


#if DEBUG
#Preview {
    struct VideoViewPreviewWrapper: View {
        @State private var navigationPath = NavigationPath()
        
        private let previewVideo = Video(
            title: "How to Install the App and Connet Omron Device",
            youtubeId: "y2ziZVWossE",
            orderIndex: 1
        )
        
        
        var body: some View {
            NavigationStack(path: $navigationPath) {
                Button("Tap Here") {
                    navigationPath.append(previewVideo)
                }
                    .navigationDestination(for: Video.self) { video in
                        VideoView(video)
                    }
            }
        }
    }
    
    return VideoViewPreviewWrapper()
}
#endif
