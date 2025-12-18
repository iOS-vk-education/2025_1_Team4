import SwiftUI
import AVFoundation

extension CreateNoteView {
    var topToolbar: some View {
        HStack(spacing: 18) {
            
            Button {
                // Если есть noteID, значит это редактирование существующей заметки
                // (открыто через navigation из ShowNoteView) - используем только dismiss
                if noteID != nil {
                    dismiss()
                } else {
                    // Новая заметка (открыта через таб) - возвращаемся на предыдущий таб
                    // previousTab содержит таб, с которого пользователь перешел на создание заметки
                    selectedTab.wrappedValue = previousTab.wrappedValue
                }
            } label: {
                toolbarIcon(systemName: "arrow.left")
            }
            
            Button {
                withAnimation(.easeInOut) {
                    togglePreviewMode()
                }
            } label: {
                toolbarIcon(systemName: stage == .reading ? "square.and.pencil" : "book")
            }
            
            Menu {
                Button("Опубликовать") { persistNote(isPublished: true) }
                    .disabled(!hasContent || isSaving)
                Button("Сохранить черновик") { persistNote(isPublished: false) }
                    .disabled(!hasContent || isSaving)
            } label: {
                toolbarIcon(systemName: "checkmark")
            }
            .disabled(stage == .creating || stage == .infoHint || isSaving)
            
            Spacer()

            Menu {
                Button("Справка") {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                showHint.toggle()
                    }
                }
                
                if isPublishedFlag && noteID != nil {
                    Button("Снять с публикации", role: .destructive) {
                        showUnpublishAlert = true
                    }
                }
                
                if noteID != nil {
                    Button("Удалить", role: .destructive) {
                        showDeleteAlert = true
                    }
                }
            } label: {
                toolbarIcon(systemName: "ellipsis")
            }
            .disabled(stage == .reading)
            .opacity(stage == .reading ? 0 : 1)
            .animation(.easeInOut(duration: 0.2), value: stage)
            .alert("Удалить заметку", isPresented: $showDeleteAlert) {
                Button("Отмена", role: .cancel) { }
                Button("Удалить", role: .destructive) {
                    deleteNote()
                }
            } message: {
                Text("Вы уверены, что хотите удалить эту заметку? Это действие нельзя отменить.")
            }
            .alert("Снять с публикации", isPresented: $showUnpublishAlert) {
                Button("Отмена", role: .cancel) { }
                Button("Снять", role: .destructive) {
                    unpublishNote()
                }
            } message: {
                Text("Заметка будет снята с публикации и станет черновиком.")
            }
            .popover(isPresented: $showHint, attachmentAnchor: .rect(.bounds), arrowEdge: .top) {
                hintPopover
                    .frame(width: 260)
                    .padding()
                    .presentationCompactAdaptation(.none)
            }
        }
        .padding(.horizontal, 32)
    }
    
    func toolbarIcon(systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(Color.adaptiveText(colorScheme: colorScheme))
    }
    
    func togglePreviewMode() {
        if stage == .reading {
            stage = hasContent ? .editing : .creating
        } else if hasContent {
            stage = .reading
        }
    }
    
    func addTextSection() {
        withAnimation {
            sections.append(.textSection())
            let id = sections.last!.id
            focusedTextSectionID = id
        }
    }
    
    @discardableResult
    func addImageSection() -> NoteComposerSection {
        let newSection = NoteComposerSection.imageSection()
        withAnimation {
//             sections.append(.imageSection())
            
            sections.append(newSection)
            focusedTextSectionID = sections.last!.id
        }
        return newSection
    }
    
    func checkCameraPermissionAndOpen(sectionID: UUID) {
        // Проверяем доступность камеры
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            return
        }
        
        // Сохраняем sectionID перед проверкой разрешения
        cameraSectionID = sectionID
        
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            // Разрешение есть, открываем камеру с небольшой задержкой
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.showCamera = true
            }
        case .notDetermined:
            // Запрашиваем разрешение
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        // Небольшая задержка перед открытием камеры
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self.showCamera = true
                        }
                    } else {
                        self.cameraSectionID = nil
                        self.showCameraPermissionAlert = true
                    }
                }
            }
        case .denied, .restricted:
            // Разрешение отклонено, показываем alert
            cameraSectionID = nil
            showCameraPermissionAlert = true
        @unknown default:
            cameraSectionID = nil
            showCameraPermissionAlert = true
        }
    }
    
    func removeSection(_ sectionID: UUID) {
        withAnimation {
            sections.removeAll { $0.id == sectionID }
            photoSelections.removeValue(forKey: sectionID)
            if sections.isEmpty {
                sections.append(.textSection())
            }
        }
    }
    
    func persistNote(isPublished: Bool) {
        guard hasContent && !isSaving else { return }
        let createContentItemRequests = sections.compactMap { $0.makeCreateContentItemRequest() }
        guard !createContentItemRequests.isEmpty else { return }
        
        isSaving = true
        savingMessage = isPublished ? "Публикуется..." : "Сохраняется..."
        
        let sanitizedTitle = noteTitle.trimmed.isEmpty ? "Без названия" : noteTitle.trimmed
        let palette: [Color] = [
            Color(red: 0.95, green: 0.98, blue: 1.0),
            Color(red: 0.97, green: 0.93, blue: 1.0),
            Color(red: 0.99, green: 0.94, blue: 0.88),
            Color(red: 0.90, green: 0.96, blue: 0.93)
        ]

        let createNoteRequest = CreateNoteRequest(
            title: sanitizedTitle,
            color: palette.randomElement() ?? Color(red: 0.95, green: 0.98, blue: 1.0),
            isPublished: isPublished,
            owner: userStorage.currentUser!,
            content: createContentItemRequests,
        )
        
        Task {
            do {
                let dbNote = try await NotesManager.instance.createNote(createNoteRequest: createNoteRequest)
                await MainActor.run {
                    isPublishedFlag = isPublished
                    stage = .reading
                    isSaving = false
                    savingMessage = nil
                }
                // Обновляем список заметок в фоне, не блокируя UI
                Task {
                    await notesStorage.loadNotes()
                }
                print("Create new note with nid: \(dbNote.nid)")
            } catch {
                await MainActor.run {
                    isSaving = false
                    savingMessage = "Ошибка сохранения"
                    // Убираем сообщение об ошибке через 2 секунды
                    Task {
                        try? await Task.sleep(nanoseconds: 2_000_000_000)
                        await MainActor.run {
                            savingMessage = nil
                        }
                    }
                }
                print("Create new note error: \(error)")
            }
        }
    }
    
    func deleteNote() {
        guard let nid = noteID else { return }
        
        isSaving = true
        savingMessage = "Удаляется..."
        
        Task {
            do {
                try await NotesManager.instance.deleteNote(nid: nid)
                await MainActor.run {
                    notesStorage.loadNotes()
                    isSaving = false
                    savingMessage = nil
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    savingMessage = "Ошибка удаления"
                    Task {
                        try? await Task.sleep(nanoseconds: 2_000_000_000)
                        await MainActor.run {
                            savingMessage = nil
                        }
                    }
                }
                print("Delete note error: \(error)")
            }
        }
    }
    
    func unpublishNote() {
        guard let nid = noteID else { return }
        
        isSaving = true
        savingMessage = "Снимается с публикации..."
        
        Task {
            do {
                try await NotesManager.instance.unpublishNote(nid: nid)
                await MainActor.run {
                    isPublishedFlag = false
                    notesStorage.loadNotes()
                    isSaving = false
                    savingMessage = nil
                }
            } catch {
                await MainActor.run {
                    isSaving = false
                    savingMessage = "Ошибка"
                    Task {
                        try? await Task.sleep(nanoseconds: 2_000_000_000)
                        await MainActor.run {
                            savingMessage = nil
                        }
                    }
                }
                print("Unpublish note error: \(error)")
            }
        }
    }
    
    @ViewBuilder
    func savingIndicator(message: String) -> some View {
        HStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(0.8)
            Text(message)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Color.black.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.bottom, 50)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

