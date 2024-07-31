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
    @Environment(NavigationPathWrapper.self) private var navigationPath
    
    
    var body: some View {
        @Bindable var navigationPath = navigationPath
        
        
        NavigationStack(path: $navigationPath.path) {
            List {
                ForEach(videoManager.videoCollections.sorted(by: { $0.orderIndex < $1.orderIndex })) { videoCollection in
                    ExpandableListCard(
                        label: {
                            VideoSectionLabel(videoCollection: videoCollection)
                        },
                        content: {
                            VideoCollectionStack(videos: videoCollection.videos)
                        }
                    )
                }
            }
                .expandableCardListStyle()
                .navigationTitle("Education")
                .toolbar {
                    if AccountButton.shouldDisplay {
                        AccountButton(isPresented: $presentingAccount)
                    }
                }
        }
            .navigationDestination(for: Video.self) { video in
                VideoView(video)
            }
    }
}


#if DEBUG
#Preview {
    Education(presentingAccount: .constant(false))
        .previewWith(standard: ENGAGEHFStandard()) {
            VideoManager()
        }
}
#endif
