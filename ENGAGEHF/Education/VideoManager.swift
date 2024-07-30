//
// This source file is part of the ENGAGE-HF project based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import OSLog
import Spezi
import SpeziFirebaseConfiguration


@Observable
class VideoManager: Module, EnvironmentAccessible {
    @ObservationIgnored @Dependency private var configureFirebaseApp: ConfigureFirebaseApp
    @ObservationIgnored @StandardActor private var standard: ENGAGEHFStandard
    
    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    private let logger = Logger(subsystem: "ENGAGEHF", category: "VideosManager")
    
    var videoCollections: [VideoCollection] = []
    
    
    func configure() {
        if ProcessInfo.processInfo.isPreviewSimulator {
            return
        }
        
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            if let user {
                Task {
                    guard let collections = await self?.getVideoSections(user: user) else {
                        return
                    }
                    self?.videoCollections = collections
                }
            }
        }
    }
    
    
    private func getVideoSections(user: User) async -> [VideoCollection] {
        self.logger.debug("Fetching educational videos.")
        var videoCollections: [VideoCollection] = []
        
        guard let videoSectionDocuments = try? await Firestore.videoSectionsCollectionReference.getDocuments().documents else {
            self.logger.error("Failed to fetch documents from video sections collection.")
            return []
        }
        
        for sectionDocument in videoSectionDocuments {
            let videosCollectionReference = sectionDocument.reference.collection("videos")
               
            // Retrieve the videos from the videos subcollection
            let videoDocuments: [QueryDocumentSnapshot]
            do {
                videoDocuments = try await videosCollectionReference.getDocuments().documents
            } catch {
                self.logger.error("Failed to fetch videos for section \(sectionDocument.documentID): \(error)")
                continue
            }
            
            let videos = videoDocuments.compactMap {
                do {
                    return try $0.data(as: Video.self)
                } catch {
                    self.logger.error("Failed to decode video: \(error)")
                    return nil
                }
            }
            
            // Decode additional context from the document such as section title and description
            let sectionContext: VideoCollectionContext
            do {
                sectionContext = try sectionDocument.data(as: VideoCollectionContext.self)
            } catch {
                self.logger.error("Failed to decode section context: \(error)")
                continue
            }
            
            videoCollections.append(VideoCollection(context: sectionContext, videos: videos))
        }
        
        self.logger.debug("Finished fetching educational videos.")
        return videoCollections
    }
}
