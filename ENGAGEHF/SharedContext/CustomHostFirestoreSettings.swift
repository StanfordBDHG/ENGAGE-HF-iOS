//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziFirestore


extension FirestoreSettings {
    static func withCustomHost(_ host: String) -> FirestoreSettings {
        let settings = FirestoreSettings()
        settings.host = "\(host):8080"
        settings.cacheSettings = MemoryCacheSettings()
        settings.isSSLEnabled = false
        return settings
    }
}
