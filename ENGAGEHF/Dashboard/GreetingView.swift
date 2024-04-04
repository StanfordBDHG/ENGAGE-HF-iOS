//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//
//  GreetingView.swift
//  ENGAGEHF
//
//  Created by Nick Riedman on 4/4/24.
//

import SwiftUI

struct Greeting: View {
    @State private var dateString: String?
    
    var body: some View {
        HStack {
            // Todo: replace world! with first name from account info
            Text("Hello, world!")
                .font(.title2)
                .accessibilityLabel(Text("DASHBOARD_GREETING"))
            Spacer()
            Text(dateString ?? "No date")
                .font(.title2)
                .accessibilityLabel(Text("DASHBOARD_DATE"))
        }
        .padding()
        .task {
            getDateString()
        }
    }
    
    private func getDateString() {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .short
        
        dateString = dateFormatter.string(from: currentDate)
    }
}
