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
final class VideoManager: Module, EnvironmentAccessible, DefaultInitializable {
    @ObservationIgnored @Dependency(ConfigureFirebaseApp.self) private var configureFirebaseApp

    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?
    private let logger = Logger(subsystem: "ENGAGEHF", category: "VideosManager")
    
    var videoCollections: [VideoCollection] = []
    
    
    init() {}
    
    
    func configure() {
#if DEBUG || TEST
        if ProcessInfo.processInfo.isPreviewSimulator || FeatureFlags.setupTestVideos {
            self.injectMockVideoCollection()
            return
        }
#endif
        
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


#if DEBUG || TEST
extension VideoManager {
    private func injectMockVideoCollection() {
        self.videoCollections = [
            VideoCollection(
                context: VideoCollectionContext(
                    title: "ENGAGE-HF Application",
                    description: "Helpful videos on the ENGAGE-HF mobile application.",
                    orderIndex: 1,
                    id: "1"
                ),
                videos: [
                    Video(
                        title: "No Description",
                        youtubeId: "y2ziZVWossE",
                        orderIndex: 1,
                        id: "2"
                    ),
                    Video(
                        title: "Short Description",
                        youtubeId: "XfgcXkq61k0",
                        orderIndex: 2,
                        description: """
                        Welcome to our step-by-step guide on getting started with our app and connecting your Omron devices! \
                        In this video, we’ll walk you through the installation process, from downloading the app to setting \
                        it up on your device. You'll learn how to seamlessly connect your Omron weight scales and blood \
                        pressure cuffs, ensuring your health data is accurately tracked and monitored. Whether you’re a \
                        first-time user or need a refresher, this tutorial will make the process easy and straightforward. \
                        Watch now to get the most out of your app and start monitoring your health with ease!
                        """
                    ),
                    Video(
                        title: "Long Description",
                        youtubeId: "VUImvk3CNik",
                        orderIndex: 3,
                        description: """
                        Welcome to our step-by-step guide on getting started with our app and connecting your Omron devices! \
                        In this video, we’ll walk you through the installation process, from downloading the app to setting \
                        it up on your device. You'll learn how to seamlessly connect your Omron weight scales and blood \
                        pressure cuffs, ensuring your health data is accurately tracked and monitored. Whether you’re a \
                        first-time user or need a refresher, this tutorial will make the process easy and straightforward. \
                        Watch now to get the most out of your app and start monitoring your health with ease!
                        
                        ENGAGE-HF features seemless bluetooth connectivity that allows you to pair your devices and take \
                        measurements without ever leaving the app. Simply set your device to pair-mode, and ENGAGE-HF will \
                        automatically connect with the device and ask if you would like to pair. Then, whenever you take a \
                        measurement, that measurement will automatically show up on the app!
                        """
                    )
                ]
            )
        ]
    }
}
#endif
