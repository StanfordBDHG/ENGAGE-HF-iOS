//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Charts
import Foundation
import SwiftUI


/// If `CustomChartYAxis` is non-nil, `VitalsGraph` will use it instead of the default axis lines.
struct CustomChartYAxis: EnvironmentKey {
    static let defaultValue: AnyAxisContent? = nil
}


extension EnvironmentValues {
  var customChartYAxis: AnyAxisContent? {
    get { self[CustomChartYAxis.self] }
    set { self[CustomChartYAxis.self] = newValue }
  }
}
