//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import OSLog
import Spezi
import SpeziViews
import SwiftUI


@main
struct ENGAGEHF: App {
    static var appName: String? {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String
    }


    @UIApplicationDelegateAdaptor(ENGAGEHFDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .testingSetup()
                .spezi(appDelegate)
        }
    }
}
