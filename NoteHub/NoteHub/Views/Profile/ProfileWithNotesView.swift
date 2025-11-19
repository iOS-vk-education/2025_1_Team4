//
//  ProfileWithNotesView.swift
//  NoteHub
//
//  Created by Evgeniy Pavlov on 20.11.2025.
//

import Foundation
import SwiftUI

struct ProfileWithNotesView: View {
    let notes: [Note]
    @Binding var showSettings: Bool
    let notesCount: Int
    let publishedCount: Int
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color("Main_Background")
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                ProfileHeaderView(
                    username: "petrpetrov",
                    notesCount: notesCount,
                    publishedCount: publishedCount,
                    showSettings: $showSettings
                )
                
                ScrollView {
                    LazyVStack(spacing: 24) {
                        ForEach(notes) { note in
                            NavigationLink {
                                ShowNoteView(note:note)
                            } label: {
                                NoteCardView(note: note)
                                    .padding(.horizontal, 32)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 12)
                }
            }
        }
    }
}
