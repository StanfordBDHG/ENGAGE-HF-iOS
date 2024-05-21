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
    
    var body: some View {
        DisclosureGroup(
            content: {
                Text(notification.description)
            },
            label: {
                Text(notification.title)
                    .bold()
            }
        )
    }
}


#Preview {
    let dummyNotification = Notification(
        title: "Weight Recorded",
        description: "A weight measurement has been recorded.",
        id: "test"
    )
    return NotificationRow(notification: .constant(dummyNotification))
}
