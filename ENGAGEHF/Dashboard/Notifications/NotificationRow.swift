//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct NotificationRow: View {
    @Binding var notification: Notification
    @State private var showDetails = false
    
    var body: some View {
        VStack {
            HStack {
                
            }
            
            if showDetails {
                Text(notification.description)
            }
        }
    }
}


#Preview {
    var dummyNotification = Notification(
        title: "Weight Recorded",
        description: "A weight measurement has been recorded.",
        id: "test"
    )
    return NotificationRow(notification: .constant(dummyNotification))
}
