//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


struct FieldDetails: Identifiable {
    let id = UUID()
    
    var title: String
    var value: Double?
}
