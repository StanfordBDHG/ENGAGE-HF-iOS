//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


/// Wrapper for passing any ViewModifier as a parameter to a view
/// Accepts a ViewModifier, applies it to the content View, and returns the modified view
struct AnyModifier: ViewModifier {
    private let bodyClosure: (Content) -> AnyView
    
    init<Modifier: ViewModifier>(_ modifier: Modifier) {
        self.bodyClosure = { content in
            AnyView(content.modifier(modifier))
        }
    }
    
    func body(content: Content) -> some View {
        bodyClosure(content)
    }
}
