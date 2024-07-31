//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct VideoCollectionStack: View {
    let videos: [Video]
    
    
    var body: some View {
        LazyVStack(alignment: .leading) {
            ForEach(videos) { video in
                HStack {
                    Image(systemName: "pill.fill")
                        .accessibilityLabel("Thumbnail \(video.title)")
                        .foregroundStyle(.accent)
                    Text(video.title)
                        .font(.subheadline.bold())
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.accent)
                        .accessibilityLabel("Navigate Button \(video.title)")
                }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        print("Navigate to \(video.title)")
                    }
            }
        }
    }
}


#if DEBUG
#Preview {
    VideoCollectionStack(
        videos: [
            Video(title: "Welcome Video", youtubeId: "y2ziZVWossE", orderIndex: 1)
        ]
    )
}
#endif
