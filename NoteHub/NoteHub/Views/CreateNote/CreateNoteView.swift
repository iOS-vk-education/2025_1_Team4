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
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var notesStore: NotesStore
    @EnvironmentObject var userStorage: UserStorage
    
    @State var stage: Stage = .creating
    @State var noteTitle: String = ""
    @State var sections: [NoteComposerSection] = [.textSection()]
    @State var draggingSection: NoteComposerSection?
    @State var isPublishedFlag: Bool = false
    @State var showHint: Bool = false
    @State var photoSelections: [UUID: PhotosPickerItem?] = [:]
    
    init() { }

     init(note: Note) {
        _noteTitle = State(initialValue: note.title)

        _sections = State(initialValue: note.content.map { item in
            switch item {
            case .text(_, let value):
                return NoteComposerSection(kind: .text, text: value)

            case .image(_, let resource):
                switch resource {
                case .data(let data):
                    return NoteComposerSection(kind: .image, imageData: data)
                case .asset:
                    return NoteComposerSection(kind: .image)
                }
            }
        })
        
         _isPublishedFlag = State(initialValue: note.isPublished)

        _stage = State(initialValue: .editing)
    }

    var body: some View {
        ZStack {
            Color("Main_Background")
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                topToolbar
                editor
            }
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
        .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
    }
}

#Preview {
    CreateNoteView()
        .environmentObject(NotesStore())
        .environmentObject(UserStorage())
}

