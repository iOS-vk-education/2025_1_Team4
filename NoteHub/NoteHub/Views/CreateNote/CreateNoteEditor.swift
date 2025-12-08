import SwiftUI
import PhotosUI
import MarkdownUI

extension CreateNoteView {
    var editor: some View {
        VStack(alignment: .leading, spacing: 18) {
            if stage == .reading {
                HStack {
                    Text("Режим чтения")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(isPublishedFlag ? "Опубликовано" : "Черновик")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(isPublishedFlag ? .green : .orange)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background((isPublishedFlag ? Color.green.opacity(0.15) : Color.orange.opacity(0.15)))
                        .clipShape(Capsule())
                }
            }
            
            ZStack {
                            editableContent
                                .opacity(stage == .reading ? 0 : 1)
                                .allowsHitTesting(stage != .reading)

                            readingContent
                                .opacity(stage == .reading ? 1 : 0)
                                .allowsHitTesting(stage == .reading)
                        }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("Modal_Background"))
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Готово") {
                    UIApplication.shared.endEditing()
                }
            }
        }
    }
    
    private var editableContent: some View {
        ScrollView {
            VStack(spacing: 14) {
                TextField("Заголовок", text: $noteTitle, axis: .vertical)
                    .font(.title3.weight(.semibold))
                    .padding(.leading, 24)
                    .padding(.vertical, 16)
                    .background(Color(red: 0.97, green: 0.98, blue: 1.0))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .onChange(of: noteTitle) { _, _ in handleTextChange() }
                
                ForEach($sections) { $section in
                    draggableSectionRow(for: $section)
                }
                
                addSectionButtons
            }
        }
        .frame(maxWidth: .infinity, minHeight: 360)
    }
    
    private var readingContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if !noteTitle.trimmed.isEmpty {
                    Text(noteTitle.trimmed)
                        .font(.title3.weight(.semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                ForEach(sections) { section in
                    previewSection(section)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 360)
    }
    
    @ViewBuilder
    private func draggableSectionRow(for section: Binding<NoteComposerSection>) -> some View {
        HStack(alignment: .top, spacing: 8) {
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 40)

                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.secondary)
                    .padding(.leading, 8)
            }
            .contentShape(Rectangle())
            .onDrag {
                draggingSection = section.wrappedValue

                let provider = NSItemProvider()
                let typeIdentifier = "com.notehub.note-section"

                provider.registerDataRepresentation(
                    forTypeIdentifier: typeIdentifier,
                    visibility: .all
                ) { completion in
                    completion(Data(), nil)
                    return nil
                }

                return provider
            }
            
            
            sectionCard(for: section)
        }
        .onDrop(
            of: ["com.notehub.note-section"],
            delegate: SectionDropDelegate(
                item: section.wrappedValue,
                sections: $sections,
                draggingItem: $draggingSection
            )
        )
    }

    @ViewBuilder
    private func sectionCard(for section: Binding<NoteComposerSection>) -> some View {
        switch section.wrappedValue.kind {
        case .text:
            textSectionCard(for: section)
        case .image:
            imageSectionCard(for: section)
        }
    }
    
    @ViewBuilder
    private func textSectionCard(for section: Binding<NoteComposerSection>) -> some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: section.text)
                .scrollContentBackground(.hidden)
                .padding()
                .background(Color(red: 0.97, green: 0.98, blue: 1.0))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .onChange(of: section.wrappedValue.text) { _, _ in handleTextChange() }
            
            if section.wrappedValue.text.trimmed.isEmpty {
                Text("Введите текст")
                    .foregroundColor(.secondary)
                    .padding(.leading, 24)
                    .padding(.vertical, 16)
            }
        }
        .overlay(alignment: .topTrailing) {
            removeButton(for: section.wrappedValue.id)
        }
    }
    
    @ViewBuilder
    private func imageSectionCard(for section: Binding<NoteComposerSection>) -> some View {
        let sectionID = section.wrappedValue.id
        PhotosPicker(selection: pickerBinding(for: sectionID), matching: .images) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(red: 0.97, green: 0.98, blue: 1.0))
                    .frame(minHeight: 200)
                
                if let data = section.wrappedValue.imageData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 36, weight: .medium))
                            .foregroundColor(.blue)
                        Text("Добавить фотографию")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .overlay(alignment: .topTrailing) {
            removeButton(for: sectionID)
        }
    }
    
    @ViewBuilder
    private func removeButton(for sectionID: UUID) -> some View {
        if sections.count > 1 {
            Button {
                removeSection(sectionID)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.gray.opacity(0.8))
                    .padding(8)
            }
        }
    }
    
    private var addSectionButtons: some View {
        VStack(spacing: 12) {
            Divider()
                .padding(.top, 8)
            
            HStack(spacing: 0) {
                Menu {
                    Button("Добавить фото") {
                        addImageSection()
                    }
                                
                    Button("Снять фото") {
                        addImageSection()
                    }
                } label: {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.blue)
                        .padding(.trailing, 20)
                        .padding(.leading, 12)
                        .frame(height: 52)
                }
                
                addSectionButton(title: "Добавить текст", /*systemImage: "plus.circle", */isPrimary: true) {
                    addTextSection()
                }
            }
        }
        .opacity(stage == .reading ? 0 : 1)
        .allowsHitTesting(stage != .reading)
        .animation(.easeInOut(duration: 0.2), value: stage)
    }
    
    private func pickerBinding(for sectionID: UUID) -> Binding<PhotosPickerItem?> {
        Binding(
            get: { photoSelections[sectionID] ?? nil },
            set: { newValue in
                photoSelections[sectionID] = newValue
                if newValue != nil {
                    Task {
                        await loadImage(for: sectionID, item: newValue)
                    }
                }
            }
        )
    }
    
    private func loadImage(for sectionID: UUID, item: PhotosPickerItem?) async {
        guard let item else { return }
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                await MainActor.run {
                    if let index = sections.firstIndex(where: { $0.id == sectionID }) {
                        sections[index].imageData = data
                        handleTextChange()
                    }
                    photoSelections[sectionID] = nil
                }
            }
        } catch {
            await MainActor.run {
                photoSelections[sectionID] = nil
            }
        }
    }
    
    func handleTextChange() {
        if stage == .creating || stage == .infoHint {
            stage = .editing
        }
    }
    
    var hasContent: Bool {
        if !noteTitle.trimmed.isEmpty { return true }
        return sections.contains { !$0.isEmpty }
    }
    
    @ViewBuilder
    private func previewSection(_ section: NoteComposerSection) -> some View {
        switch section.kind {
        case .text:
            let trimmed = section.text.trimmed
            if trimmed.isEmpty {
                EmptyView()
            } else {
                let sanitized = sanitizeMarkdown(trimmed)
                Markdown(sanitized)
                    .markdownTheme(.gitHub)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        case .image:
            if let data = section.imageData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
        }
    }
    
    @ViewBuilder
    private func addSectionButton(title: String, /*systemImage: String, */isPrimary: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
//                Image(systemName: systemImage)
//                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isPrimary ? Color.blue : Color.gray.opacity(0.2))
            .foregroundColor(isPrimary ? .white : .blue)
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }
}

struct SectionDropDelegate: DropDelegate {
    let item: NoteComposerSection
    @Binding var sections: [NoteComposerSection]
    @Binding var draggingItem: NoteComposerSection?
    
    func dropEntered(info: DropInfo) {
        guard let draggingItem else {
            return
        }
        if draggingItem == item {
            return
        }
        
        guard let fromIndex = sections.firstIndex(of: draggingItem),
              let toIndex = sections.firstIndex(of: item) else { return }
        
        
        if sections[toIndex] != draggingItem {
            withAnimation(.default) {
                sections.move(
                    fromOffsets: IndexSet(integer: fromIndex),
                    toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex
                )
            }
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        draggingItem = nil
        return true
    }
}
