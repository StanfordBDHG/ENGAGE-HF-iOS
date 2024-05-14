//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct ToDoRow: View {
    @Binding var task: ToDoItem
    @State var taskComplete = false
    
    var body: some View {
        HStack {
            Text(task.task)
            Spacer()
            Button {
                taskComplete.toggle()
            } label: {
                Image(systemName: taskComplete ? "checkmark.square" : "square")
            }
        }
    }
}


// TODO: Add onDelete functionality / backwards update to record completed task
struct ToDoRows: View {
    @Binding var tasks: [ToDoItem]
    
    var body: some View {
        if !tasks.isEmpty {
            ForEach($tasks, id: \.id) { task in
                ToDoRow(task: task)
            }
        } else {
            Text("Nothing to do!")
        }
    }
}

#Preview {
    let tasks: [ToDoItem] = []
    return ToDoRows(tasks: .constant(tasks))
}
