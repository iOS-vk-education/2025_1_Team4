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
        NavigationStack {
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
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onAppear {
            showEmptyState = false //пока менять руками на фолс чтобы увидеть непустой профиль
            
            if !showEmptyState && store.notes.isEmpty {
                store.addSample()
            }
        }
    }
}

#Preview {
    ProfileView()
}
