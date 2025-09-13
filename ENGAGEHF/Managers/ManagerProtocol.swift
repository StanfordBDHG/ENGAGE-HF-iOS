//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Spezi


/// A protocol to force refresh of the content of conforming Managers.
protocol RefreshableContent {
    // periphery:ignore - Actually used in the invitation code module.
    func refreshContent()
}


/// A `Manager` is a `Spezi` `Module` that is environment accessible, default initializable (for dependencies between modules),
/// and supportive of content refreshes.
protocol Manager: Module, EnvironmentAccessible, DefaultInitializable, RefreshableContent {}
