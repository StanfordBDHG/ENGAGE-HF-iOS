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
    let youtubeId: String
    
    @State private var viewState: ViewState = .processing
    
    
    var body: some View {
        ZStack {
            WebView(urlString: "https://youtube.com/embed/\(youtubeId)", viewState: $viewState)
                .aspectRatio(16 / 9, contentMode: .fit)
            if viewState == .processing {
                ProgressView()
                    .background(.clear)
            }
        }
            .background(.clear)
            .viewStateAlert(state: $viewState)
    }
}


#Preview {
    VideoPlayer(youtubeId: "y2ziZVWossE")
}
