//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct VideoPlayer: View {
    let youtubeId: String
    
    
    var body: some View {
        WebView(urlString: "https://youtube.com/embed/\(youtubeId)")
            .aspectRatio(16 / 9, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding()
    }
}


#Preview {
    VideoPlayer(youtubeId: "y2ziZVWossE")
}
