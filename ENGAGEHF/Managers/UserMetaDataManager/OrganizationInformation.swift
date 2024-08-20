//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziContact


struct OrganizationIdentifier: Decodable {
    let organization: String?
}


struct OrganizationInformation: Decodable {
    let name: String
    let contactName: String
    let phoneNumber: String
    let emailAddress: String
    
    
    var contact: Contact {
        Contact(
            name: {
                do {
                    return try PersonNameComponents(contactName)
                } catch {
                    return PersonNameComponents()
                }
            }(),
            title: "Site Lead",
            organization: name,
            contactOptions: [
                .call(phoneNumber),
                .email(addresses: [emailAddress])
            ]
        )
    }
}
