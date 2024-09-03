//
//  Account+Setup.swift
//  ENGAGEHF
//
//  Created by Paul Kraft on 03.09.2024.
//

import FirebaseFunctions
import SpeziAccount

extension Account {
    func setup() async throws {
        do {
            print("Calling setupUser")
            _ = try await Functions.functions().httpsCallable("setupUser").call()
            print("Called setupUser")
            try await Task.sleep(for: .seconds(20))
            throw CancellationError()
        } catch {
            print("Failed setupUser", error)
            await removeUserDetails()
            throw error
        }
    }
}
