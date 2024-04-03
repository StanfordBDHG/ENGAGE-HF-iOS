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

struct Greeting: View {
    @State private var dateString: String?
    
    var body: some View {
        HStack {
            Text("Hello, world!")
                .font(.title2)
            Spacer()
            Text(dateString ?? "No date")
                .font(.title2)
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

struct Dashboard: View {
    @Binding var presentingAccount: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                Greeting()
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("ENGAGE-HF: Home")  // Todo: Make this white
            
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    AccountButton(isPresented: $presentingAccount)
                        .foregroundColor(.white)
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color("AccentColor"), for: .navigationBar)
        }
    }
}

#Preview {
    @State var presentingAccount = false
    return Dashboard(presentingAccount: $presentingAccount)
}
