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
    private let video: Video
    
    
    var body: some View {
        VStack(spacing: 20) {
            VideoPlayer(youtubeId: video.youtubeId)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            if let description = video.description, !description.isEmpty {
                ScrollableText(description) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemBackground))
                }
                    .accessibilityIdentifier("Video Description: \(video.title)")
            }
            Spacer()
        }
            .padding(.horizontal)
            .padding(.top)
            .background(Color(.systemGroupedBackground))
            .navigationTitle(video.title)
            .navigationBarTitleDisplayMode(.inline)
    }
    
    
    init(_ video: Video) {
        self.video = video
    }
}


#if DEBUG
#Preview("Small Text") {
    struct VideoViewPreviewWrapper: View {
        @Environment(NavigationManager.self) private var navigationManager
        
        
        private let previewVideo = Video(
            title: "How to Install the App and Connet Omron Device",
            youtubeId: "y2ziZVWossE",
            orderIndex: 1,
            description: """
            Welcome to our step-by-step guide on getting started with our app and connecting your Omron devices! \
            In this video, we’ll walk you through the installation process, from downloading the app to setting \
            it up on your device. You'll learn how to seamlessly connect your Omron weight scales and blood \
            pressure cuffs, ensuring your health data is accurately tracked and monitored. Whether you’re a \
            first-time user or need a refresher, this tutorial will make the process easy and straightforward. \
            Watch now to get the most out of your app and start monitoring your health with ease!
            """
        )
        
        
        var body: some View {
            @Bindable var navigationManager = navigationManager
            
            NavigationStack(path: $navigationManager.path) {
                Button("Tap Here") {
                    navigationManager.path.append(previewVideo)
                }
                    .navigationDestination(for: Video.self) { video in
                        VideoView(video)
                    }
            }
        }
    }
    
    return VideoViewPreviewWrapper()
        .previewWith(standard: ENGAGEHFStandard()) {
            NavigationManager()
        }
}

#Preview("Massive Text") {
    struct VideoViewPreviewWrapper: View {
        @Environment(NavigationManager.self) private var navigationManager
        
        
        private let previewVideo = Video(
            title: "How to Install the App and Connet Omron Device",
            youtubeId: "y2ziZVWossE",
            orderIndex: 1,
            description: """
            Welcome to our step-by-step guide on getting started with our app and connecting your Omron devices! \
            In this video, we’ll walk you through the installation process, from downloading the app to setting \
            it up on your device. You'll learn how to seamlessly connect your Omron weight scales and blood \
            pressure cuffs, ensuring your health data is accurately tracked and monitored. Whether you’re a \
            first-time user or need a refresher, this tutorial will make the process easy and straightforward. \
            Watch now to get the most out of your app and start monitoring your health with ease!
                                        
            ENGAGE-HF features seemless bluetooth connectivity that allows you to pair your devices and take \
            measurements without ever leaving the app. Simply set your device to pair-mode, and ENGAGE-HF will \
            automatically connect with the device and ask if you would like to pair.
            """
        )
        
        
        var body: some View {
            @Bindable var navigationManager = navigationManager
            
            NavigationStack(path: $navigationManager.path) {
                Button("Tap Here") {
                    navigationManager.path.append(previewVideo)
                }
                    .navigationDestination(for: Video.self) { video in
                        VideoView(video)
                    }
            }
        }
    }
    
    return VideoViewPreviewWrapper()
        .previewWith(standard: ENGAGEHFStandard()) {
            NavigationManager()
        }
}
#endif
