//
//  NoteHubApp.swift
//  NoteHub
//
//  Created by Evgeniy Pavlov on 06.11.2025.
//

import SwiftUI
import Firebase

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct NoteHubApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var userStorage = UserStorage()
    @StateObject private var notesStore = NotesStore()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if userStorage.currentUser == nil {
                    WelcomeView()
                } else {
                    MainTabView()
                }
//                if userStorage.isLoggedIn {
//                    MainTabView()
//                } else {
//                    WelcomeView()
//                }
            }
            .onAppear {
                userStorage.loadUser()
            }
            .environmentObject(userStorage)
            .environmentObject(notesStore)
        }
    }
}
