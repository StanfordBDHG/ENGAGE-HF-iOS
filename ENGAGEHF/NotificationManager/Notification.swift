//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import Foundation


/// A notification
///
/// Mirrors the representation of a notification in firestore
/// When assigned to a patient, the title will be displayed
/// and the description will be displayed in a drop-down field
struct Notification: Identifiable, Equatable, Codable {
    @DocumentID var id: String?
    var type: String
    var title: String
    var description: String
    var created: Timestamp
    var completed: Bool
}
