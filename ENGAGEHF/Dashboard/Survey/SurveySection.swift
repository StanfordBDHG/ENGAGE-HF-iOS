//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


enum SurveyStatus: String {
    case available
    case unavailable
    case unfinished
    case done
}


struct SurveySection: View {
    @State private var surveyStatus: SurveyStatus = .unavailable
    @Binding var showFullSurvey: Bool
    
    var body: some View {
        Section("Survey") {
            HStack {
                Text("Survey: \(surveyStatus.rawValue)")
                
                Spacer()
                
                if surveyStatus == .available {
                    Button(
                        action: {
                            showFullSurvey.toggle()
                        },
                        label: {
                            Circle()
                                .fill(.green)
                                .frame(width: 10, height: 10)
                    })
                }
            }
        }
        .headerProminence(.increased)
        
        .task {
            do {
                try await self.getSurveyStatus()
            } catch {
                print("Unable to get survey status: \(error)")
            }
        }
    }
    
    // TODO: Finish this
    func getSurveyStatus() async throws {
        surveyStatus = .available
    }
}

#Preview {
    SurveySection(showFullSurvey: .constant(false))
}
