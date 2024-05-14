//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseAuth
import FirebaseFirestore
import SpeziViews
import SwiftUI


struct ToDoSection: View {
    @State private var tasks: [ToDoItem] = []
    @State private var state: ViewState = .idle
    
    @State private var tasksLoaded = false
    
    
    var body: some View {
        Section("To-do") {
            if state == .idle {
                ToDoRows(tasks: $tasks)
            } else {
                HStack {
                    Text("Loading To-do List...")
                    Spacer()
                    ProgressView()
                }
            }
        }
        .headerProminence(.increased)
        
        .task {
            if !tasksLoaded {
                do {
                    try await getTasks()
                } catch {
                    print("Could not get tasks: \(error)")
                }
            }
        }
    }
    
    // TODO: Finish this function
    func getTasks() async throws {
        state = .processing
        
        self.tasks.append(ToDoItem(id: "test1", task: "Take a weight measurement"))
        self.tasks.append(ToDoItem(id: "test2", task: "Take a BP measurement"))
        self.tasks.append(ToDoItem(id: "test3", task: "Watch the welcome video"))
        
        print("Successfully loaded tasks!")
        state = .idle
        tasksLoaded = true
    }
}

#Preview {
    ToDoSection()
}
