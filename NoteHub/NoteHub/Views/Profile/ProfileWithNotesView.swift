import SwiftUI

/// Тип фильтра заметок в профиле
enum ProfileNotesFilter: String, CaseIterable, Identifiable {
    case drafts
    case published
    case all
    
    var id: String { rawValue }
    
    /// Текст в дропдауне
    var menuTitle: String {
        switch self {
        case .drafts:    return "Только черновики"
        case .published: return "Только опубликованные"
        case .all:       return "Все"
        }
    }
    
    /// Текст в чипе под статистикой
    var chipTitle: String {
        switch self {
        case .drafts:    return "только черновики"
        case .published: return "только опубликованные"
        case .all:       return ""
        }
    }
}

/// Выпадающее меню фильтра
struct ProfileFilterMenu: View {
    let selected: ProfileNotesFilter
    let onSelect: (ProfileNotesFilter) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(ProfileNotesFilter.allCases) { filter in
                Button {
                    onSelect(filter)
                } label: {
                    HStack {
                        Text(filter.menuTitle)
                            .font(.system(size: 15))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                }
                
                if filter != ProfileNotesFilter.allCases.last {
                    Divider()
                }
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 6)
    }
}

struct ProfileWithNotesView: View {
    let username: String
    let notes: [DBNote]
    @Binding var showSettings: Bool
    let notesCount: Int
    let publishedCount: Int
    
    @State private var selectedFilter: ProfileNotesFilter = .all
    @State private var showFilterMenu = false
    
    // Отфильтрованные заметки
    private var filteredNotes: [DBNote] {
        switch selectedFilter {
        case .all:
            return notes
        case .drafts:
            // мои и не опубликованные
            return notes.filter { !$0.isPublished && $0.owner.name == username }
        case .published:
            // мои и опубликованные
            return notes.filter { $0.isPublished && $0.owner.name == username }
        }
    }
    
    private var isFilterActive: Bool {
        selectedFilter != .all
    }
    
    var body: some View {
        ZStack {
            Color("Main_Background")
                .edgesIgnoringSafeArea(.all)
            
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 0) {
                    ProfileHeaderView(
                        username: username,
                        notesCount: notesCount,
                        publishedCount: publishedCount,
                        showSettings: $showSettings,
                        showsFilter: notesCount > 0,
                        isFilterActive: isFilterActive,
                        filterTitle: isFilterActive ? selectedFilter.chipTitle : nil,
                        onFilterTap: {
                            if notesCount > 0 {
                                withAnimation {
                                    showFilterMenu.toggle()
                                }
                            }
                        },
                        onClearFilterTap: {
                            withAnimation {
                                selectedFilter = .all
                                showFilterMenu = false
                            }
                        }
                    )
                    
                    ScrollView {
                        LazyVStack(spacing: 24) {
                            ForEach(filteredNotes) { note in
                                NavigationLink {
                                    ShowNoteView(note: note)
                                } label: {
                                    NoteCardView(note: note)
                                        .padding(.horizontal, 32)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.top, 12)
                    }
                }
                
                if showFilterMenu {
                    ProfileFilterMenu(
                        selected: selectedFilter,
                        onSelect: { filter in
                            withAnimation {
                                selectedFilter = filter
                                showFilterMenu = false
                            }
                        }
                    )
                    .padding(.trailing, 32)
                    .padding(.top, 120)
                }
            }
        }
    }
}

#Preview {
    // моковые данные для превью
    let notes = NoteMocks.notes
    
    ProfileWithNotesView(
        username: "petrpetrov",
        notes: notes,
        showSettings: .constant(false),
        notesCount: notes.count,
        publishedCount: 1
    )
}
