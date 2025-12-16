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
    
    @EnvironmentObject var userStorage: UserStorage
    
    @State var stage: Stage = .creating
    @State var noteTitle: String = ""
    @State var sections: [NoteComposerSection] = [.textSection()]
    @State var draggingSection: NoteComposerSection?
    @State var isPublishedFlag: Bool = false
    @State var showHint: Bool = false
    @State var photoSelections: [UUID: PhotosPickerItem?] = [:]
    @State var isSaving: Bool = false
    @State var savingMessage: String? = nil
    @State var showCamera: Bool = false
    @State var cameraImage: UIImage? = nil
    @State var cameraSectionID: UUID? = nil
    @State var showCameraPermissionAlert: Bool = false
    
    init() { }

     init(note: DBNote) {
        _noteTitle = State(initialValue: note.title)

        _sections = State(initialValue: note.content.map { item in
            switch item {
            case .text(_, let value):
                return NoteComposerSection(kind: .text, text: value)
            case .image(_, let dbImage):
                return NoteComposerSection(kind: .image, imageData: dbImage.data)
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
    }
}

#Preview {
    CreateNoteView()
        .environmentObject(UserStorage())
}

