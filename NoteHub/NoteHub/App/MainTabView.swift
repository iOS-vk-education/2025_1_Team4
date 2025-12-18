//
//  CustomTapBar.swift
//  NoteHub
//
//  Created by Polina Sitnikova on 17.11.2025.
//

import SwiftUI

struct MainTabView: View {
    @State var selectedTab: Tab = .main
    @State var previousTab: Tab = .main
    @State var profileNavigationPath = NavigationPath()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case .main:
                        MainPageView()
                            .environmentObject(NotesStorage())
                    case .new:
                        CreateNoteView()
                            .environment(\.selectedTab, $selectedTab)
                            .environment(\.previousTab, $previousTab)
                            .environment(\.goToProfile, {
                                // Полностью сбрасываем navigation path профиля, чтобы закрыть все открытые экраны
                                profileNavigationPath = NavigationPath()
                                // Затем переключаем таб на профиль
                                selectedTab = .profile
                            })
                            .environment(\.profileNavigationPath, $profileNavigationPath)
                    case .profile:
                        ProfileView()
                            .environment(\.profileNavigationPath, $profileNavigationPath)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                CustomTabBar(selectedTab: $selectedTab)
            }
            .ignoresSafeArea(.keyboard)
            .onChange(of: selectedTab) { oldValue, newValue in
                // Когда переключаемся на "новую заметку", сохраняем текущий таб как предыдущий
                if newValue == .new && oldValue != .new {
                    previousTab = oldValue
                }
                // При переключении на профиль полностью сбрасываем navigation path профиля
                if newValue == .profile {
                    profileNavigationPath = NavigationPath()
                }
            }
        }
    }
}

// Environment key для передачи selectedTab binding
struct SelectedTabKey: EnvironmentKey {
    static let defaultValue: Binding<Tab> = .constant(.main)
}

extension EnvironmentValues {
    var selectedTab: Binding<Tab> {
        get { self[SelectedTabKey.self] }
        set { self[SelectedTabKey.self] = newValue }
    }
}

// Environment key для передачи previousTab binding
struct PreviousTabKey: EnvironmentKey {
    static let defaultValue: Binding<Tab> = .constant(.main)
}

extension EnvironmentValues {
    var previousTab: Binding<Tab> {
        get { self[PreviousTabKey.self] }
        set { self[PreviousTabKey.self] = newValue }
    }
}

// Environment key для передачи функции перехода в профиль
struct GoToProfileKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var goToProfile: () -> Void {
        get { self[GoToProfileKey.self] }
        set { self[GoToProfileKey.self] = newValue }
    }
}

// Environment key для передачи profileNavigationPath binding
struct ProfileNavigationPathKey: EnvironmentKey {
    static let defaultValue: Binding<NavigationPath> = .constant(NavigationPath())
}

extension EnvironmentValues {
    var profileNavigationPath: Binding<NavigationPath> {
        get { self[ProfileNavigationPathKey.self] }
        set { self[ProfileNavigationPathKey.self] = newValue }
    }
}

enum Tab: Int {
    case main = 0
    case new
    case profile
}

#Preview {
    MainTabView()
        .environmentObject(UserStorage())
}
