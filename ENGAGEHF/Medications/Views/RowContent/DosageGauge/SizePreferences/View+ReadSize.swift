//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//
// Based on: https://www.fivestars.blog/articles/swiftui-share-layout-information/
//

import Foundation
import SwiftUI


extension View {
    func readSize<T: PreferenceKey>(_ key: T.Type, onChange: @escaping (CGSize) -> Void) -> some View where T.Value == CGSize {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: key, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(key, perform: onChange)
    }
}
