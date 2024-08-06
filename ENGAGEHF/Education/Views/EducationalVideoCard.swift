//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct EducationalVideoCard: View {
    let video: Video
    
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ThumbnailView(youtubeId: video.youtubeId, aspectRatio: CGSize(width: 2558, height: 1330))
            
            HStack {
                VStack(alignment: .leading) {
                    Text(video.title)
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    if let description = video.description, !description.isEmpty {
                        Text(description)
                            .font(.headline.bold())
                            .foregroundStyle(.white.opacity(0.75))
                            .lineLimit(1)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .accessibilityLabel("Education Video Inspect Button")
                    .foregroundStyle(.white)
            }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .padding(.top, 32)
                .background {
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .black]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
        }
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}


#if DEBUG
#Preview {
    List {
        EducationalVideoCard(
            video: Video(
                title: "Welcome Video 1",
                youtubeId: "y2ziZVWossE",
                orderIndex: 1
            )
        )
        EducationalVideoCard(
            video: Video(
                title: "Welcome Video 2",
                youtubeId: "y2ziZVWossE",
                orderIndex: 1,
                description: "Welcome video description"
            )
        )
    }
        .listRowInsets(.init())
}
#endif
