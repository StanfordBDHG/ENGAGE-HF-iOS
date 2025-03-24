//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//


struct PhoneNumberArray: Sendable, Equatable, Codable {
    var numbers: [String]
    
    init(_ numbers: [String] = []) {
        self.numbers = numbers
    }
}
