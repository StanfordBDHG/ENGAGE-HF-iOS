//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct VideoListSection: View {
    private struct Header: View {
        let title: String
        let subtitle: String
        @Binding var isExpanded: Bool
        
        
        var body: some View {
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline.bold())
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.primary.opacity(0.5))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.accent)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .accessibilityLabel("Section Expander")
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    isExpanded.toggle()
                }
            }
        }
    }
    
    
    let title: String
    let subtitle: String
    let videos: [Video]
    
    @Environment(NavigationManager.self) private var navigationManager
    @State private var isExpanded = true
    
    
    var body: some View {
        LazyVStack(spacing: 12) {
            Header(title: title, subtitle: subtitle, isExpanded: $isExpanded)
            
            ZStack {
                if isExpanded {
                    LazyVStack(spacing: 12) {
                        ForEach(videos.sorted(by: { $0.orderIndex < $1.orderIndex })) { video in
                            EducationalVideoCard(video: video)
                                .onTapGesture {
                                    navigationManager.path.append(video)
                                }
                        }
                    }
                }
            }
                .frame(maxWidth: .infinity)
        }
    }
}


#if DEBUG
#Preview("Welcome Video") {
    ScrollView {
        LazyVStack(spacing: 12) {
            VideoListSection(
                title: "ENGAGE-HF Application",
                subtitle: "Helpful videos on the ENGAGE-HF mobile application.",
                videos: [Video(title: "Welcome Video", youtubeId: "y2ziZVWossE", orderIndex: 1)]
            )
        }
    }
        .previewWith(standard: ENGAGEHFStandard()) {
            NavigationManager()
        }
}

#Preview("Invalid Video") {
    ScrollView {
        LazyVStack(spacing: 12) {
            VideoListSection(
                title: "ENGAGE-HF Application",
                subtitle: "Helpful videos on the ENGAGE-HF mobile application.",
                videos: [Video(title: "Welcome Video", youtubeId: "1", orderIndex: 1)]
            )
        }
    }
        .previewWith(standard: ENGAGEHFStandard()) {
            NavigationManager()
        }
}
#endif
