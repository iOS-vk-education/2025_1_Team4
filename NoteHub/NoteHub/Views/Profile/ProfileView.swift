//
//  ProfileView.swift
//  NoteHub
//
//  Created by Polina Sitnikova on 17.11.2025.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var store = NotesStore()
    @State private var showSettings = false
    @State private var showEmptyState = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if showEmptyState {
                    EmptyProfileView(showSettings: $showSettings)
                } else {
                    ProfileWithNotesView(
                        notes: store.notes,
                        showSettings: $showSettings,
                        notesCount: store.notes.count,
                        publishedCount: store.publishedCount
                    )
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onAppear {
            showEmptyState = true //пока менять руками на фолс чтобы увидеть непустой профиль
            
            if !showEmptyState && store.notes.isEmpty {
                store.addSample()
            }
        }
    }
}

struct ProfileWithNotesView: View {
    let notes: [Note]
    @Binding var showSettings: Bool
    let notesCount: Int
    let publishedCount: Int
    
    var body: some View {
        VStack(spacing: 0) {
            ProfileHeaderView(
                username: "petrpetrov",
                notesCount: notesCount,
                publishedCount: publishedCount,
                showSettings: $showSettings
            )
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(notes) { note in
                        NoteCard(note: note)
                    }
                }
                .padding()
            }
            .background(Color(red: 0.95, green: 0.97, blue: 1.0))
            
            Spacer()
            
            CustomTabBar(activeTab: .profile)
        }
        .background(Color(red: 0.95, green: 0.97, blue: 1.0))
    }
}
