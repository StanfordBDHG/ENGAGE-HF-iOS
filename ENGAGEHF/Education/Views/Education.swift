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
    
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(videoManager.videoCollections.sorted(by: { $0.orderIndex < $1.orderIndex })) { videoCollection in
                    ExpandableListCard(
                        label: {
                            VideoSectionLabel(videoCollection: videoCollection)
                        },
                        content: {
                            Text("")
                        }
                    )
                }
            }
                .headerProminence(.increased)
                .navigationTitle("Education")
                .toolbar {
                    if AccountButton.shouldDisplay {
                        AccountButton(isPresented: $presentingAccount)
                    }
                }
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
