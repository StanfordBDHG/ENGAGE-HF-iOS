//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


extension VitalsGraph {
    struct GestureOverlay: ViewModifier {
        let viewModel: ViewModel
        
        
        func body(content: Content) -> some View {
            content
                .chartOverlay { proxy in
                    GeometryReader { geometry in
                        Rectangle().fill(.clear)
                            .contentShape(Rectangle())
                            .gesture(
                                SpatialTapGesture()
                                    .onEnded { value in
                                        viewModel.selectPoint(value: value, proxy: proxy, geometry: geometry, clearOnGap: true)
                                    }
                            )
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        viewModel.selectPoint(value: value, proxy: proxy, geometry: geometry, clearOnGap: false)
                                    }
                            )
                    }
                }
        }
    }
}
