//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseAuth
import Foundation
import OSLog
import Spezi
import SwiftUI


/// Navigation Manager
///
/// Wraps an environment accessible and observable stack for use in navigating between views
@Observable
class NavigationManager: Module, EnvironmentAccessible {
    private let logger = Logger(subsystem: "ENGAGEHF", category: "NavigationManager")
    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    
    var path = NavigationPath()
    
    
    // On sign in, reinitialize to an empty navigation path
    func configure() {
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if user != nil {
                self?.logger.debug("Reinitializing navigation path.")
                self?.path = NavigationPath()
            }
        }
    }
}
