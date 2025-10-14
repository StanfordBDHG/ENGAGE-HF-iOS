//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziContact


struct Organization: Decodable {
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


#if DEBUG
extension Organization {
    static let test = Organization(
        name: "Stanford University",
        contactName: "Leland Stanford Jr.",
        phoneNumber: "(111) 111-1111",
        emailAddress: "leland@stanford.edu"
    )
}
#endif
