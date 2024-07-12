//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// A structure for storing measurements ready for display
/// Contains all the necessary information for display in the VitalsList in the All Data and Graph sections
struct VitalMeasurement: Identifiable, Hashable {
    var id: String?

    var value: String
    var date: Date
}
