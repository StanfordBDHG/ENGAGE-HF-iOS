//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// Make String conform to Identifiable for use in SwiftUI `.sheet(item:content:)` modifier
extension String: Identifiable {
    public var id: String { self }
}
