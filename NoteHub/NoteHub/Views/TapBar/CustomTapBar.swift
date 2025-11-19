//
//  CustomTapBar.swift
//  NoteHub
//
//  Created by Evgeniy Pavlov on 20.11.2025.
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Tab

    var body: some View {
        HStack {
            Button(action: { selectedTab = .main }) {
                TabItemView(
                    title: "Главная",
                    isActive: selectedTab == .main,
                    systemImage: "house"
                )
            }
            .frame(maxWidth: .infinity)

            Button(action: { selectedTab = .new }) {
                TabItemView(
                    title: "Новая заметка",
                    isActive: selectedTab == .new,
                    systemImage: "plus.circle"
                )
            }
            .frame(maxWidth: .infinity)
            
            Button(action: { selectedTab = .profile }) {
                TabItemView(
                    title: "Профиль",
                    isActive: selectedTab == .profile,
                    systemImage: "person"
                )
            }
            .frame(maxWidth: .infinity)
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
