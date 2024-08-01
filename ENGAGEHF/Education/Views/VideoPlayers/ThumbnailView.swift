//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct ThumbnailView: View {
    let youtubeId: String
    
    
    private var imageURLString: String {
        "https://img.youtube.com/vi/\(youtubeId)/maxresdefault.jpg"
    }
    
    
    var body: some View {
        Color.clear
            .overlay {
                AsyncImage(url: URL(string: imageURLString)) { phase in
                    switch phase {
                    case .failure:
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.yellow)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .accessibilityLabel("Unknown Thumbnail")
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .accessibilityLabel("\(youtubeId) Thumbnail")
                    default:
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .aspectRatio(2558 / 1330, contentMode: .fit)
            .clipped()
    }
}


#Preview(traits: .sizeThatFitsLayout) {
    ThumbnailView(youtubeId: "VUImvk3CNik")
}
