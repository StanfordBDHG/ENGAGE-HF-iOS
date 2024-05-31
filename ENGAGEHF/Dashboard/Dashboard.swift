//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct Dashboard: View {
    @Binding var presentingAccount: Bool
    @State var showSurvey = false
    
    
    var body: some View {
        NavigationStack {
            List {
                // Notifications
                NotificationSection()
                
                // To-do
                ToDoSection()
                
                // Most recent vitals
                RecentVitalsSection()
                
                // Survey, if available
                SurveySection(showFullSurvey: $showSurvey)
            }
            .studyApplicationList()
            .sheet(isPresented: $showSurvey) {
                FullSurveyView()
            }
            .navigationTitle("Home")
            .toolbar {
                if AccountButton.shouldDisplay {
                    AccountButton(isPresented: $presentingAccount)
                }
            }
        }
    }
}


#Preview {
    Dashboard(presentingAccount: .constant(false))
        .previewWith(standard: ENGAGEHFStandard()) {
            NotificationManager()
        }
}
