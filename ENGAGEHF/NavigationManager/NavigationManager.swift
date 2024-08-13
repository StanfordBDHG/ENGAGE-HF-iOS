//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseAuth
import Foundation
import OSLog
import Spezi
import SpeziFirebaseConfiguration
import SwiftUI


/// Navigation Manager
///
/// Wraps an environment accessible and observable stack for use in navigating between views
@MainActor
@Observable
final class NavigationManager: Module, EnvironmentAccessible, DefaultInitializable {
    @ObservationIgnored @Dependency private var configureFirebaseApp: ConfigureFirebaseApp
    @ObservationIgnored @Dependency private var videoManager: VideoManager
    
    private let logger = Logger(subsystem: "ENGAGEHF", category: "NavigationManager")
    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    
    var educationPath = NavigationPath()
    var medicationsPath = NavigationPath()
    var heartHealthPath = NavigationPath()
    var homePath = NavigationPath()
    
    var selectedTab: HomeView.Tabs = .home
    var questionnaireId: String?
    var showHealthSummary = false
    
    
    nonisolated init() {}
    
    
    // On sign in, reinitialize to an empty navigation path
    func configure() {
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if user != nil {
                self?.logger.debug("Reinitializing navigation path.")
                
                self?.educationPath = NavigationPath()
                self?.medicationsPath = NavigationPath()
                self?.heartHealthPath = NavigationPath()
                self?.homePath = NavigationPath()
                
                self?.selectedTab = .home
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
        case .showHealthSummary:
            self.showHealthSummary = true
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
}
