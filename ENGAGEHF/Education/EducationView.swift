//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//
//  EducationView.swift
//  ENGAGEHF
//
//  Created by Nick Riedman on 4/3/24.
//

import SwiftUI

struct Education: View {
    @Binding var presentingAccount: Bool
    
    var body: some View {
        Text("Education Test")
            .accessibilityLabel(Text("EDU"))
    }
}
