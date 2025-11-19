//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct VideoPlayer: View {
    // swiftlint:disable:next force_unwrapping
    private static let youtubeEmbedUrl = URL(string: "https://youtube.com/embed")!
    
    let youtubeId: String
    
    @State private var viewState: ViewState = .processing
    
    private var request: URLRequest {
        let url = VideoPlayer.youtubeEmbedUrl.appending(component: youtubeId)
        var request = URLRequest(url: url)
        request.setValue("http://localhost", forHTTPHeaderField: "Referer")
        return request
    }
    
    var body: some View {
        WebView(request: request, viewState: $viewState)
            .aspectRatio(16 / 9, contentMode: .fit)
            .overlay {
                if viewState == .processing {
                    ZStack {
                        ThumbnailView(youtubeId: youtubeId, aspectRatio: CGSize(width: 16, height: 9))
                        ProgressView()
                            .tint(.gray)
                    }
                        .opacity(0.75)
                        .transition(.opacity)
                }
            }
            .animation(.default, value: viewState)
            .viewStateAlert(state: $viewState)
    }
}


#Preview {
    VideoPlayer(youtubeId: "y2ziZVWossE")
}
