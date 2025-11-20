//
//  MainPageView.swift
//  NoteHub
//
//  Created by Evgeniy Pavlov on 17.11.2025.
//

import SwiftUI

struct MainPageView: View {
    @State private var searchText = ""
    @EnvironmentObject private var notesStore: NotesStore
    
    private var filteredNotes: [Note] {
        guard !searchText.isEmpty else { return notesStore.notes }
        return notesStore.notes.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.preview.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color("Main_Background")
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 12) {
                    SearchBarView(searchText: $searchText)
                    
                    ScrollView {
                        LazyVStack(spacing: 24) {
                            ForEach(filteredNotes) { note in
                                NavigationLink {
                                    ShowNoteView(note: note)
                                } label: {
                                    NoteCardView(note: note)
                                        .padding(.horizontal, 32)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct MainPageView_Previews: PreviewProvider {
    static var previews: some View {
        MainPageView()
            .environmentObject(NotesStore())
    }
}

