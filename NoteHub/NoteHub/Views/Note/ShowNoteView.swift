//
//  ShowNoteView.swift
//  NoteHub
//
//  Created by Evgeniy Pavlov on 18.11.2025.
//

import SwiftUI

struct ShowNoteView: View {
    let note: Note
    @Environment(\.dismiss) private var dismiss
    
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
                        Menu {
                            Button(action: {
                                // TODO
                            }) {
                                Label("Сохранить", systemImage: "plus.square.on.square")
                            }
                            
                            Button(action: {
                                // TODO
                            }) {
                                Label("Предложить правку", systemImage: "paperplane")
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
                        
                        ForEach(note.content, id: \.id) { item in
                            switch item {
                            case .text(let text):
                                Text(text)
                                    .font(.body)
                                    .foregroundColor(.black)
                            case .image(let imageName):
                                NavigationLink {
                                    FullscreenImageView(imageName: imageName)
                                } label: {
                                    Image(imageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: .infinity)
                                        .clipped()
                                }
                                .buttonStyle(.plain)
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
    }
}

#Preview {
    NavigationStack {
        ShowNoteView(note: NoteMocks.notes.first!)
    }
}
