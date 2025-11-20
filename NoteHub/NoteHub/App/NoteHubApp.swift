//
//  NoteHubApp.swift
//  NoteHub
//
//  Created by Evgeniy Pavlov on 06.11.2025.
//

import SwiftUI

@main
struct NoteHubApp: App {
    @StateObject private var userStorage = UserStorage()
    @StateObject private var notesStore = NotesStore()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if userStorage.isLoggedIn {
                    MainTabView()
                } else {
                    WelcomeView()
                }
            }
            .environmentObject(userStorage)
            .environmentObject(notesStore)
        }
    }
}
