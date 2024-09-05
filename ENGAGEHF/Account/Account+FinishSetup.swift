//
//  Account+Setup.swift
//  ENGAGEHF
//
//  Created by Paul Kraft on 03.09.2024.
//

import FirebaseFunctions
import SpeziAccount

extension Account {
    func finishSetupIfNeeded() async throws {
        do {
            _ = try await Functions.functions().httpsCallable("setupUser").call()
        } catch {
            print("Failed setupUser", error)
            await removeUserDetails()
            throw error
        }
    }
}
