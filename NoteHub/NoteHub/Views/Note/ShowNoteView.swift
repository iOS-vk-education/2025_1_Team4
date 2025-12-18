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
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var userStorage: UserStorage
    @State private var isEditing = false
    @State private var loadedImages: [String: UIImage] = [:]
    
    private var textColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(red: 0x2C/255.0, green: 0x2C/255.0, blue: 0x2C/255.0) : .white
    }

    var body: some View {
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
                .foregroundColor(textColor)
                
                Spacer()
                
                ZStack(alignment: .topTrailing) {
                    if note.owner.name == userStorage.currentUser!.name {
                        Button(action: {
                            isEditing = true
                        }) {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 24, weight: .medium))
                                .foregroundColor(textColor)
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
                                .foregroundColor(textColor)
                                .padding(.trailing, 6)
                        }
                    }
                    
                }
                .frame(width: 44, height: 44)
            }
            .padding(.horizontal, 16)
            .frame(height: 56)
            .background(Color("Main_Background"))
            
            ScrollView(showsIndicators: true) {
                VStack(alignment: .leading, spacing: 20) {
                    Text(note.title)
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                        .foregroundColor(textColor)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 12)
                    
                    ForEach(Array(note.content.enumerated()), id: \.offset) { index, item in
                        switch item {
                        case .text(_, let value):
                            VStack(alignment: .leading, spacing: 0) {
                                Markdown(sanitizeMarkdown(value))
                                    .markdownTheme(.docC)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.clear)
                            .padding(0)
                        case .image(let ncid, let image):
                            AsyncImageView(ncid: ncid, image: image, loadedImages: $loadedImages)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(backgroundColor)
                .padding(.bottom, 16)
            }
            .background(backgroundColor)
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $isEditing) {
            CreateNoteView(note: note)
        }
    }
}

// Компонент для асинхронной загрузки изображений
struct AsyncImageView: View {
    let ncid: String
    let image: DBImage
    @Binding var loadedImages: [String: UIImage]
    @State private var isLoading = false
    
    var body: some View {
        Group {
            if let uiImage = loadedImages[ncid] {
                NavigationLink {
                    FullscreenImageView(uiImage: uiImage)
                } label: {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .clipped()
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, alignment: .center)
            } else if image.data.isEmpty {
                // Изображение еще не загружено - загружаем по требованию
                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 200)
                    
                    if isLoading {
                        ProgressView()
                    } else {
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    }
                }
                .onAppear {
                    loadImage()
                }
            } else if let uiImage = UIImage(data: image.data) {
                NavigationLink {
                    FullscreenImageView(uiImage: uiImage)
                } label: {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .clipped()
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, alignment: .center)
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
    
    private func loadImage() {
        guard !isLoading else { return }
        isLoading = true
        
        Task {
            do {
                let imageData = try await NoteContentItemManager.instance.loadImageData(urlString: image.url)
                if let uiImage = UIImage(data: imageData) {
                    await MainActor.run {
                        loadedImages[ncid] = uiImage
                        isLoading = false
                    }
                } else {
                    await MainActor.run {
                        isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ShowNoteView(note: NoteMocks.notes.first!).environmentObject(UserStorage())
    }
}
