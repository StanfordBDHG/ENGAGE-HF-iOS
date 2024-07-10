//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import HealthKit


extension HKObject {
    var externalUUID: UUID? {
        guard let string = metadata?[HKMetadataKeyExternalUUID] as? String else {
            return nil
        }
        
        return UUID(uuidString: string)
    }
}
