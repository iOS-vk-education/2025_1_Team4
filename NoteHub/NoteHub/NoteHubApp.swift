//
//  NoteHubApp.swift
//  NoteHub
//
//  Created by Evgeniy Pavlov on 06.11.2025.
//

import SwiftUI

@main
struct NoteHubApp: App {
    var isLoggedIn: Bool = false
    
//    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                // главная
                ContentView()
            } else {
                WelcomeView()
            }
        }
    }
}
