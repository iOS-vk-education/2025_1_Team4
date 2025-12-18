//
//  CreateNoteView.swift
//  NoteHub
//
//  Updated by Tolepbek Temirlan on 20.11.2025.
//

import SwiftUI
import PhotosUI
import AVFoundation

struct CreateNoteView: View {
    enum Stage {
        case creating
        case editing
        case reading
        case infoHint
    }
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.selectedTab) var selectedTab
    @Environment(\.previousTab) var previousTab
    @Environment(\.goToProfile) var goToProfile
    @Environment(\.profileNavigationPath) var profileNavigationPath
    
    @EnvironmentObject var userStorage: UserStorage
    @EnvironmentObject var notesStorage: NotesStorage
    
    @State var stage: Stage = .creating
    @State var noteTitle: String = ""
    @State var sections: [NoteComposerSection] = [.textSection()]
    @State var draggingSection: NoteComposerSection?
    @State var isPublishedFlag: Bool = false
    @State var showHint: Bool = false
    @State var photoSelections: [UUID: PhotosPickerItem?] = [:]
    @FocusState var focusedTextSectionID: UUID?
    @FocusState var isTitleFocused: Bool
    @State var isSaving: Bool = false
    @State var savingMessage: String? = nil
    @State var showCamera: Bool = false
    @State var cameraImage: UIImage? = nil
    @State var cameraSectionID: UUID? = nil
    @State var showCameraPermissionAlert: Bool = false
    @State var showPhotoLibrary: Bool = false
    @State var photoLibraryImage: UIImage? = nil
    @State var photoLibrarySectionID: UUID? = nil
    @State var noteID: String? = nil
    @State var showDeleteAlert: Bool = false
    @State var showUnpublishAlert: Bool = false
    @State var noteForEditing: DBNote? = nil // Сохраняем заметку для загрузки изображений
    
    init() { }

     init(note: DBNote) {
        _noteTitle = State(initialValue: note.title)
        _noteID = State(initialValue: note.nid)
        _noteForEditing = State(initialValue: note)

        // Загружаем секции, для изображений загружаем данные асинхронно
        var initialSections: [NoteComposerSection] = []
        for item in note.content {
            switch item {
            case .text(_, let value):
                initialSections.append(NoteComposerSection(kind: .text, text: value))
            case .image(_, let dbImage):
                // Если данные пустые (lazy loading), создаем секцию без данных
                // Данные будут загружены позже через task
                initialSections.append(NoteComposerSection(kind: .image, imageData: dbImage.data.isEmpty ? nil : dbImage.data))
            }
        }
        _sections = State(initialValue: initialSections)
        
         _isPublishedFlag = State(initialValue: note.isPublished)

        _stage = State(initialValue: .editing)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color("Main_Background")
                    .ignoresSafeArea()
                    .onTapGesture {
                        // Закрываем клавиатуру при тапе вне полей ввода
                        isTitleFocused = false
                        focusedTextSectionID = nil
                    }
                
                VStack(spacing: 16) {
                    topToolbar
                    editor
                }
            }
            .keyboardDoneButton()
            .navigationBarHidden(true)
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
        .overlay(alignment: .bottom) {
            if let message = savingMessage {
                savingIndicator(message: message)
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraView(isPresented: $showCamera, capturedImage: $cameraImage)
                .onAppear {
                    // Дополнительная проверка при появлении
                    let status = AVCaptureDevice.authorizationStatus(for: .video)
                    if status != .authorized || !UIImagePickerController.isSourceTypeAvailable(.camera) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showCamera = false
                            if status == .denied || status == .restricted {
                                showCameraPermissionAlert = true
                            }
                        }
                    }
                }
        }
        .sheet(isPresented: $showPhotoLibrary) {
            PhotoLibraryPickerView(isPresented: $showPhotoLibrary, selectedImage: $photoLibraryImage)
        }
        .alert("Доступ к камере", isPresented: $showCameraPermissionAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Настройки") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
        } message: {
            Text("Для съемки фото необходимо разрешить доступ к камере. Перейдите в настройки приложения и разрешите использование камеры.")
        }
        .onChange(of: cameraImage) { _, newImage in
            if let image = newImage, let sectionID = cameraSectionID {
                if let imageData = image.jpegData(compressionQuality: 0.8) {
                    if let index = sections.firstIndex(where: { $0.id == sectionID }) {
                        sections[index].imageData = imageData
                        handleTextChange()
                    }
                }
                // Сбрасываем после небольшой задержки
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    cameraImage = nil
                    cameraSectionID = nil
                }
            }
        }
        .onChange(of: photoLibraryImage) { _, newImage in
            if let image = newImage, let sectionID = photoLibrarySectionID {
                if let imageData = image.jpegData(compressionQuality: 0.8) {
                    if let index = sections.firstIndex(where: { $0.id == sectionID }) {
                        sections[index].imageData = imageData
                        handleTextChange()
                    }
                }
                // Сбрасываем после небольшой задержки
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    photoLibraryImage = nil
                    photoLibrarySectionID = nil
                }
            }
        }
        .onChange(of: showPhotoLibrary) { _, isShowing in
            if !isShowing {
                // Если галерея закрылась без фото, сбрасываем sectionID
                if photoLibraryImage == nil {
                    photoLibrarySectionID = nil
                }
            }
        }
        .onChange(of: showCamera) { _, isShowing in
            if !isShowing {
                // Если камера закрылась без фото, сбрасываем sectionID
                if cameraImage == nil {
                    cameraSectionID = nil
                }
            }
        }
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
        .task {
            // Загружаем данные изображений при редактировании заметки
            if let note = noteForEditing {
                await loadImagesForEditing(note: note)
            }
        }
    }
    
    private func loadImagesForEditing(note: DBNote) async {
        // Находим все секции с изображениями, у которых нет данных
        for (index, item) in note.content.enumerated() {
            if case .image(_, let dbImage) = item {
                if dbImage.data.isEmpty && !dbImage.url.isEmpty {
                    // Загружаем данные изображения
                    do {
                        let imageData = try await NoteContentItemManager.instance.loadImageData(urlString: dbImage.url)
                        await MainActor.run {
                            if index < sections.count && sections[index].kind == .image {
                                sections[index].imageData = imageData
                            }
                        }
                    } catch {
                        print("Failed to load image data for editing: \(error)")
                    }
                }
            }
        }
    }
}

#Preview {
    CreateNoteView()
        .environmentObject(UserStorage())
}

