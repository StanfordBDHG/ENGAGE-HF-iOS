//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct Education: View {
    @Binding var presentingAccount: Bool
    
    @Environment(VideoManager.self) private var videoManager
    @Environment(NavigationManager.self) private var navigationManager
    
    
    var body: some View {
        @Bindable var navigationManager = navigationManager
        
        NavigationStack(path: $navigationManager.educationPath) {
            VideoList(videoCollections: videoManager.videoCollections)
                .accessibilityIdentifier("Video List")
                .navigationTitle("Education")
                .toolbar {
                    if AccountButton.shouldDisplay {
                        AccountButton(isPresented: $presentingAccount)
                    }
                }
                .navigationDestination(for: Video.self) { video in
                    VideoView(video)
                }
        }
    }
}


#if DEBUG
#Preview {
    Education(presentingAccount: .constant(false))
        .previewWith(standard: ENGAGEHFStandard()) {
            VideoManager()
            NavigationManager()
        }
}
#endif
