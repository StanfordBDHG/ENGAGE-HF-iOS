//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import ModelsR4


/// Type Aliases defined to avoid importing ModelsR4 into files that contain @Observable classes, which are broken by overlapping namespaces between ModelsR4 and the @Observable macro.
typealias FHIRObservation = Observation
typealias FHIRObservationComponent = ObservationComponent
