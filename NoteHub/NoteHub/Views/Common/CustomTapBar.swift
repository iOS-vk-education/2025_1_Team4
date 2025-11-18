//
//  CustomTapBar.swift
//  NoteHub
//
//  Created by Polina Sitnikova on 17.11.2025.
//

import SwiftUI

struct CustomTabBar: View {
    let activeTab: Tab
    
    var body: some View {
        HStack {
            TabItem(
                title: "Главная",
                isActive: activeTab == .home,
                systemImage: "house"
            )
            
            Spacer()
            
            TabItem(
                title: "Новая заметка",
                isActive: activeTab == .newNote,
                systemImage: "plus.circle"
            )
            
            Spacer()
            
            TabItem(
                title: "Профиль",
                isActive: activeTab == .profile,
                systemImage: "person"
            )
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 16)
        .background(Color.white)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.gray.opacity(0.3)),
            alignment: .top
        )
    }
}

struct TabItem: View {
    let title: String
    let isActive: Bool
    let systemImage: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: systemImage)
                .font(.system(size: 20))
                .foregroundColor(isActive ? .black : .gray)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(isActive ? .black : .gray)
        }
    }
}

enum Tab {
    case home, newNote, profile
}
