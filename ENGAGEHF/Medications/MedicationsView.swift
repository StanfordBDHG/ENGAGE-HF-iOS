//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//
//  MedicationsView.swift
//  ENGAGEHF
//
//  Created by Nick Riedman on 4/3/24.
//

import SpeziAccount
import SpeziMockWebService
import SwiftUI

struct Medications: View {
    @Binding var presentingAccount: Bool
    
    var body: some View {
        Text("Medications Test")
            .accessibilityLabel(Text("MED"))
    }
}
