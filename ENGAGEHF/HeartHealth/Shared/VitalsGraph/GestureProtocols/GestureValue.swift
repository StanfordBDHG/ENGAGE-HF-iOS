//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// A unifying protocol for accessing the location field of a gesture
protocol GestureValue {
    /// Return the location associated with the gesture value
    var eventLocation: CGPoint { get }
}
