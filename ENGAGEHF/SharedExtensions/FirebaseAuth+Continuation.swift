//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseAuth
import Foundation


extension Auth {
    @discardableResult
    func getToken(forcingRefresh: Bool = false) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            self.getToken(forcingRefresh: forcingRefresh) { token, error in
                switch (token, error) {
                case let (.some(token), _):
                    continuation.resume(returning: token)
                case let (_, .some(error)):
                    continuation.resume(throwing: error)
                case (.none, .none):
                    continuation.resume(throwing: AuthErrorCode.nullUser)
                }
            }
        }
    }
}
