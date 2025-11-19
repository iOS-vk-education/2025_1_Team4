//
//  CustomTapBar.swift
//  NoteHub
//
//  Created by Polina Sitnikova on 17.11.2025.
//

import SwiftUI

struct MainTabView: View {
    @State var selectedTab: Tab = Tab.main

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Контент соответствующий выбранному табу
                Group {
                    switch selectedTab {
                    case .main:
                        MainPageView()
                    case .new:
                        MainPageView()
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
}
