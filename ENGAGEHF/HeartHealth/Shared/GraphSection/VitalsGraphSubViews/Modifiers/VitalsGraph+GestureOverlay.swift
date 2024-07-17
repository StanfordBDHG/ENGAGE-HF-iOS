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
        var viewModel: ViewModel
        
        func body(content: Content) -> some View {
            content
                .chartOverlay { proxy in
                    GeometryReader { geometry in
                        Rectangle().fill(.clear)
                            .contentShape(Rectangle())
                            .gesture(
                                SpatialTapGesture()
                                    .onEnded { value in
                                        print("Graph tapped")
//                                        viewModel.selectPoints(value: value, proxy: proxy, geometry: geometry)
                                    }
                            )
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        print("Graph dragged")
//                                        viewModel.selectPoints(value: value, proxy: proxy, geometry: geometry)
                                    }
                            )
                    }
                }
        }
    }
}
