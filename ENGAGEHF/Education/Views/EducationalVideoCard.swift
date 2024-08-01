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
            ThumbnailView(youtubeId: video.youtubeId)
            
            HStack {
                VStack(alignment: .leading) {
                    Text(video.title)
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(video.description ?? "Video Description")
                        .font(.headline.bold())
                        .foregroundStyle(.white.opacity(0.75))
                        .lineLimit(1)
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
            video: Video(title: "Welcome Video", youtubeId: "y2ziZVWossE", orderIndex: 1)
        )
            .listRowInsets(.init())
    }
}
#endif
