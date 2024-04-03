//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//
//  DashboardView.swift
//  ENGAGEHF
//
//  Created by Nick Riedman on 4/3/24.
//

import SpeziAccount
import SpeziMockWebService
import SwiftUI

struct HomeTitle: View {
    @Binding var presentingAccount: Bool
    
    var body: some View {
        HStack {
            titleBar
            AccountButton(isPresented: $presentingAccount)
        }
    }
    
    private var titleBar: some View {
        Text("ENGAGE-HF Home")
            .font(.title)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color("AccentColor"))
    }
}

struct Dashboard: View {
    @Binding var presentingAccount: Bool
    
    var body: some View {
        VStack {
            // Title
            
            
            // Greeting and Date
            
            // Notifications
            
            // To-Do list
            
            // Latest Vitals
            
            // Symptom Survey
        }
            .toolbar {
                AccountButton(isPresented: $presentingAccount)
            }
    }
}
