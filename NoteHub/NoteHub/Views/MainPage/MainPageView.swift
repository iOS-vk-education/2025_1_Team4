import SwiftUI

struct MainPageView: View {
    @State private var searchText = ""
    @State private var isLoading = false // TODO: сюда потом подцепить notesStore.isLoading
    @EnvironmentObject private var notesStorage: NotesStorage
    
    private var filteredNotes: [DBNote] {
        guard !searchText.isEmpty else { return notesStorage.notes }
        return notesStorage.notes.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.preview.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color("Main_Background")
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 12) {
                    SearchBarView(searchText: $searchText)
                    
                    Group {
                        if isLoading {
                            NotesLoaderView()
                        } else if !searchText.isEmpty && filteredNotes.isEmpty {
                            EmptySearchStateView(query: searchText)
                        } else {
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
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }.onAppear {
                notesStorage.loadNotes()
            }
        }
    }
}

struct NotesLoaderView: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.3)
            
            Text("Загружаем заметки…")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
// TODO: Подключение лоадера:
//пока не подключила, ждем коммиты ребят
//в NotesStore добавить @Published var isLoading = true/false
//в MainPageView(тут) заменить локальный isLoading на notesStore.isLoading см.5 строку
//при загрузке заметок выставлять:
//isLoading=true-показываем лоадер
//isLoading=false-показываем список заметок


struct EmptySearchStateView: View {
    let query: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 32))
                .foregroundColor(.gray.opacity(0.7))
            
            Text("Ничего не найдено")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
            
            Text("По запросу «\(query)» нет заметок.\nПопробуйте изменить формулировку.")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}



struct MainPageView_Previews: PreviewProvider {
    static var previews: some View {
        MainPageView()
            .environmentObject(NotesStorage())
    }
}

