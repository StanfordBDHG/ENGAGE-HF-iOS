//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import OSLog
import Spezi
import SpeziAccount
import SwiftUI


/// Navigation Manager
///
/// Wraps an environment accessible and observable stack for use in navigating between views
@MainActor
@Observable
class NavigationManager: Module, EnvironmentAccessible {
    @ObservationIgnored @Dependency(AccountNotifications.self) private var accountNotifications: AccountNotifications?
    @ObservationIgnored @Dependency(VideoManager.self) private var videoManager

    @Application(\.logger) @ObservationIgnored private var logger
    
    var educationPath = NavigationPath()
    var medicationsPath = NavigationPath()
    var heartHealthPath = NavigationPath()
    var homePath = NavigationPath()
    
    var selectedTab: HomeView.Tabs = .home
    var questionnaireId: String?

    private var notificationTask: Task<Void, Never>?

    
    // On sign in, reinitialize to an empty navigation path
    func configure() {
        if let accountNotifications {
            notificationTask = Task.detached { @MainActor [weak self] in
                for await event in accountNotifications.events {
                    guard let self else {
                        return
                    }
                    guard case .associatedAccount = event else {
                        continue
                    }

                    logger.debug("Reinitializing navigation path.")

                    educationPath = NavigationPath()
                    medicationsPath = NavigationPath()
                    heartHealthPath = NavigationPath()
                    homePath = NavigationPath()

                    selectedTab = .home
                }
            }
        }
    }
    
    
    func execute(_ messageAction: MessageAction) async -> Bool {
        self.logger.debug("Executing message action: \(messageAction.encodingString ?? "unknown")")
        
        switch messageAction {
        case let .playVideo(sectionId, videoId):
            let matchingVideo = videoManager.videoCollections
                .filter { $0.id == sectionId }
                .flatMap { $0.videos.filter { $0.id == videoId } }
                .first
            
            guard let matchingVideo else {
                self.logger.debug("No matching video found. sectionId: \(sectionId), videoId: \(videoId)")
                return false
            }
        
            await self.playVideo(matchingVideo)
            
        case .showMedications:
            self.switchHomeTab(to: .medications)
        case .showHeartHealth:
            self.switchHomeTab(to: .heart)
        case let .completeQuestionnaire(questionnaireId):
            self.questionnaireId = questionnaireId
        default:
            return false
        }
        
        return true
    }
    
    func playVideo(_ video: Video) async {
        self.switchHomeTab(to: .education)
        try? await Task.sleep(for: .seconds(0.1))
        self.pushEducation(video)
    }
    
    func pushEducation(_ video: Video) {
        self.educationPath.append(video)
    }
    
    func switchHomeTab(to newTab: HomeView.Tabs) {
        self.selectedTab = newTab
    }

    deinit {
        _notificationTask?.cancel()
    }
}
