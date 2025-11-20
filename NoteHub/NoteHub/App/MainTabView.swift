//
//  CustomTapBar.swift
//  NoteHub
//
//  Created by Polina Sitnikova on 17.11.2025.
//

import SwiftUI

struct MainTabView: View {
    @State var selectedTab: Tab = .new

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case .main:
                        MainPageView()
                    case .new:
                        CreateNoteView()
                    case .profile:
                        ProfileView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                CustomTabBar(selectedTab: $selectedTab)
            }
            .ignoresSafeArea(.keyboard)
        }
    }
}

enum Tab: Int {
    case main = 0
    case new
    case profile
}

#Preview {
    MainTabView()
        .environmentObject(NotesStore())
        .environmentObject(UserStorage())
}
