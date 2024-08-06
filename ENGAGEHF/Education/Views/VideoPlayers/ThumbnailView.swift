//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct ThumbnailView: View {
    private let youtubeId: String
    private let aspectRatio: CGSize
    
    
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
                            .accessibilityLabel("Thumbnail Image: \(youtubeId)")
                    default:
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .aspectRatio(aspectRatio, contentMode: .fit)
            .clipped()
    }
    
    
    init(youtubeId: String, aspectRatio: CGSize = CGSize(width: 16, height: 9)) {
        self.youtubeId = youtubeId
        self.aspectRatio = aspectRatio
    }
}


#Preview(traits: .sizeThatFitsLayout) {
    ThumbnailView(youtubeId: "VUImvk3CNik")
}
