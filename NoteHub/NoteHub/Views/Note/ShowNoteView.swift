//
//  ShowNoteView.swift
//  NoteHub
//
//  Created by Evgeniy Pavlov on 18.11.2025.
//

import SwiftUI
import UIKit
import MarkdownUI

struct ShowNoteView: View {
    let note: DBNote
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userStorage: UserStorage
    @State private var isEditing = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20, weight: .regular))
                            Text("Вернуться")
                                .font(.system(size: 18))
                        }
                    }
                    .foregroundColor(.black)
                    
                    Spacer()
                    
                    ZStack(alignment: .topTrailing) {
                        if note.owner.name == userStorage.currentUser!.name {
                            Button(action: {
                                isEditing = true
                            }) {
                                Image(systemName: "square.and.pencil")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.black)
                                    .padding(.trailing, 6)
                            }
                        } else {
                            Menu {
                                Button(action: {
                                    // TODO
                                }) {
                                    Label("Сохранить", systemImage: "plus.square.on.square")
                                }
                                Button(action: {
                                    // TODO
                                }) {
                                    Label("Перейти к автору", systemImage: "person")
                                }
                            } label: {
                                Image(systemName: "line.3.horizontal")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.black)
                                    .padding(.trailing, 6)
                            }
                        }
                        
                    }
                    .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 16)
                .frame(height: 56)
                .background(Color("Main_Background"))
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(note.title)
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 12)
                        
                        ForEach(note.content) { item in
                            switch item {
                            case .text(_, let value):
                                Markdown(sanitizeMarkdown(value))
                                    .markdownTheme(.gitHub)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            case .image(_, let image):
                                if let uiImage = UIImage(data: image.data) {
                                    NavigationLink {
                                        FullscreenImageView(uiImage: uiImage)
                                    } label: {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxWidth: .infinity)
                                            .clipped()
                                    }
                                } else {
                                    Rectangle()
                                        .fill(Color.orange.opacity(0.3))
                                        .frame(height: 200)
                                        .overlay(
                                            Image(systemName: "exclamationmark.triangle")
                                                .foregroundColor(.orange)
                                        )
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.white)
                    .padding(.bottom, 16)
                }
                .background(Color.white)
                
                
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
        }
        .navigationDestination(isPresented: $isEditing) {
                CreateNoteView(note: note)
            }
    }
}

#Preview {
    NavigationStack {
        ShowNoteView(note: NoteMocks.notes.first!).environmentObject(UserStorage())
    }
}
