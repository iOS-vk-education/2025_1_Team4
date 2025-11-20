import SwiftUI

extension CreateNoteView {
    var topToolbar: some View {
        HStack(spacing: 18) {
            Button {
                withAnimation(.easeInOut) {
                    togglePreviewMode()
                }
            } label: {
                toolbarIcon(systemName: stage == .reading ? "square.and.pencil" : "book")
            }
            
            Menu {
                Button("Опубликовать") { persistNote(isPublished: true) }
                    .disabled(!hasContent)
                Button("Сохранить черновик") { persistNote(isPublished: false) }
                    .disabled(!hasContent)
            } label: {
                toolbarIcon(systemName: "checkmark")
            }
            .disabled(stage == .creating || stage == .infoHint)
            
            Spacer()
            
            Button {
                addTextSection()
            } label: {
                toolbarIcon(systemName: "plus")
            }
            .disabled(stage == .reading)
            .opacity(stage == .reading ? 0 : 1)
            .animation(.easeInOut(duration: 0.2), value: stage)
            
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showHint.toggle()
                }
            } label: {
                toolbarIcon(systemName: "info.circle")
            }
            .disabled(stage == .reading)
            .opacity(stage == .reading ? 0 : 1)
            .animation(.easeInOut(duration: 0.2), value: stage)
            .popover(isPresented: $showHint, attachmentAnchor: .rect(.bounds), arrowEdge: .top) {
                hintPopover
                    .frame(width: 260)
                    .padding()
                    .presentationCompactAdaptation(.none)
            }
        }
        .padding(.horizontal, 16)
    }
    
    func toolbarIcon(systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(.black)
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
        }
    }
    
    func addImageSection() {
        withAnimation {
            sections.append(.imageSection())
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
        guard hasContent else { return }
        let contentItems = sections.compactMap { $0.makeContentItem() }
        guard !contentItems.isEmpty else { return }
        
        let sanitizedTitle = noteTitle.trimmed.isEmpty ? "Без названия" : noteTitle.trimmed
        let palette: [Color] = [
            Color(red: 0.95, green: 0.98, blue: 1.0),
            Color(red: 0.97, green: 0.93, blue: 1.0),
            Color(red: 0.99, green: 0.94, blue: 0.88),
            Color(red: 0.90, green: 0.96, blue: 0.93)
        ]
        
        let note = Note(
            title: sanitizedTitle,
            content: contentItems,
            color: palette.randomElement() ?? Color(red: 0.95, green: 0.98, blue: 1.0),
            isPublished: isPublished,
            userName: userStorage.name.isEmpty ? "Аноним" : userStorage.name
        )
        
        notesStore.add(note)
        isPublishedFlag = isPublished
        stage = .reading
    }
}

