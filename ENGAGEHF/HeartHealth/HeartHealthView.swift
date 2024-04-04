//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//
//  HeartHealthView.swift
//  ENGAGEHF
//
//  Created by Nick Riedman on 4/3/24.
//

import SwiftUI

struct HeartHealth: View {
    @Binding var presentingAccount: Bool
    
    var body: some View {
        Text("Heart Health Test")
            .accessibilityLabel(Text("HH"))
    }
}
