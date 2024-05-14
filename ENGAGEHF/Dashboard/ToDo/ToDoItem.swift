//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


struct ToDoItem: Identifiable {
    let id: String
    var task: String
    
    
    init(id: String, task: String) {
        self.id = id
        self.task = task
    }
}
