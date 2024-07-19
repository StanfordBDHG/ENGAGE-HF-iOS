//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// The name of the collections in the Firebase backend as defined in:
/// https://github.com/StanfordBDHG/ENGAGE-HF-Firebase/tree/web-data-scheme
enum CollectionID: String, CaseIterable {
    case symptomScores
    case heartRateObservations
    case bodyWeightObservations
    case bloodPressureObservations
}
