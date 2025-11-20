//
//  CreateNoteView.swift
//  NoteHub
//
//  Updated by Tolepbek Temirlan on 20.11.2025.
//

import SwiftUI
import PhotosUI

struct CreateNoteView: View {
    enum Stage {
        case creating
        case editing
        case reading
        case infoHint
    }
    
    @EnvironmentObject var notesStore: NotesStore
    @EnvironmentObject var userStorage: UserStorage
    
    @State var stage: Stage = .creating
    @State var noteTitle: String = ""
    @State var sections: [NoteComposerSection] = [.textSection()]
    @State var isPublishedFlag: Bool = false
    @State var showHint: Bool = false
    @State var photoSelections: [UUID: PhotosPickerItem?] = [:]
    
    var body: some View {
        ZStack {
            Color("Main_Background")
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                topToolbar
                editor
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 12)
        }
        .overlay(
            Color.black.opacity(showHint ? 0.2 : 0)
                .ignoresSafeArea()
                .allowsHitTesting(showHint)
                .animation(.easeInOut(duration: 0.2), value: showHint)
                .onTapGesture {
                    if showHint {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showHint = false
                        }
                    }
                }
        )
        .onChange(of: showHint) { _, newValue in
            if newValue {
                stage = .infoHint
            } else if stage == .infoHint {
                stage = hasContent ? .editing : .creating
            }
        }
        .animation(.easeInOut(duration: 0.2), value: stage)
    }
}

#Preview {
    CreateNoteView()
        .environmentObject(NotesStore())
        .environmentObject(UserStorage())
}

