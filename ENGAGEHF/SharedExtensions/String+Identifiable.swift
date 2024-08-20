//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//


#if compiler(>=6)
extension String: @retroactive Identifiable {}
#else
extension Swift.String: Swift.Identifiable {}
#endif


extension String {
    /// Make String conform to Identifiable for use in SwiftUI `.sheet(item:content:)` modifier
    public var id: String { self }
}
