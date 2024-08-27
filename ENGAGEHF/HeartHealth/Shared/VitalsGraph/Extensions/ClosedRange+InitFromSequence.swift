//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation


extension ClosedRange {
    /// Initialize a closed range over a sequence spanning from the minimum to the maximum values of the sequence.
    init?(spanning collection: some Sequence<Bound>) {
        guard let min = collection.min(),
              let max = collection.max() else {
            return nil
        }
        
        self = min...max
    }
}
