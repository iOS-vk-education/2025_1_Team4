import SwiftUI

struct MainPageView: View {
    @State private var searchText = ""
    @State private var selectedUsers: Set<String> = []
    @State private var showUserFilterMenu = false
    @State private var userSearchText = ""
    @EnvironmentObject private var notesStorage: NotesStorage
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isSearchFocused: Bool
    
    // Список всех уникальных пользователей из опубликованных заметок
    private var availableUsers: [String] {
        Array(Set(notesStorage.notes
            .filter { $0.isPublished }
            .map { $0.owner.name }))
            .sorted()
    }
    
    // Отфильтрованные пользователи для поиска в меню
    private var filteredUsers: [String] {
        guard !userSearchText.isEmpty else { return availableUsers }
        return availableUsers.filter { $0.localizedCaseInsensitiveContains(userSearchText) }
    }
    
    private var filteredNotes: [DBNote] {
        // Фильтруем только опубликованные заметки
        var publishedNotes = notesStorage.notes.filter { $0.isPublished }
        
        // Фильтруем по выбранным пользователям
        if !selectedUsers.isEmpty {
            publishedNotes = publishedNotes.filter { selectedUsers.contains($0.owner.name) }
        }
        
        // Сортируем по дате создания (сначала новые)
        let sortedNotes = publishedNotes.sorted { $0.createdAt > $1.createdAt }
        
        guard !searchText.isEmpty else { return sortedNotes }
        return sortedNotes.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.preview.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
            Color("Main_Background")
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    // Закрываем клавиатуру при тапе на фон
                    isSearchFocused = false
                    if showUserFilterMenu {
                        withAnimation {
                            showUserFilterMenu = false
                        }
                    }
                }
            
            VStack(spacing: 12) {
                SearchBarView(searchText: $searchText, isFocused: $isSearchFocused)
                
                // Горизонтальный скроллируемый список чипов с пользователями
                if !availableUsers.isEmpty {
                    VStack(spacing: 8) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                // Кнопка "Все авторы"
                                Button {
                                    withAnimation {
                                        selectedUsers.removeAll()
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "person.2.fill")
                                            .font(.system(size: 12))
                                        Text("Все авторы")
                                            .font(.system(size: 14, weight: selectedUsers.isEmpty ? .semibold : .regular))
                                    }
                                    .foregroundColor(selectedUsers.isEmpty ? .white : Color.adaptiveText(colorScheme: colorScheme))
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 14)
                                    .background(selectedUsers.isEmpty ? Color.blue : Color.adaptiveInputBackground(colorScheme: colorScheme))
                                    .clipShape(Capsule())
                                }
                                
                                // Чипы с пользователями (множественный выбор)
                                ForEach(availableUsers, id: \.self) { user in
                                    Button {
                                        withAnimation {
                                            if selectedUsers.contains(user) {
                                                selectedUsers.remove(user)
                                            } else {
                                                selectedUsers.insert(user)
                                            }
                                        }
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: selectedUsers.contains(user) ? "checkmark.circle.fill" : "person.fill")
                                                .font(.system(size: 12))
                                            Text(user)
                                                .font(.system(size: 14, weight: selectedUsers.contains(user) ? .semibold : .regular))
                                        }
                                        .foregroundColor(selectedUsers.contains(user) ? .white : Color.adaptiveText(colorScheme: colorScheme))
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 14)
                                        .background(selectedUsers.contains(user) ? Color.blue : Color.adaptiveInputBackground(colorScheme: colorScheme))
                                        .clipShape(Capsule())
                                    }
                                }
                            }
                            .padding(.horizontal, 32)
                        }
                        
                        // Кнопка для открытия меню с поиском (если пользователей много)
                        if availableUsers.count > 5 {
                            Button {
                                withAnimation {
                                    showUserFilterMenu.toggle()
                                    userSearchText = ""
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 12))
                                    Text("Найти автора")
                                        .font(.system(size: 13))
                                }
                                .foregroundColor(Color.adaptiveText(colorScheme: colorScheme).opacity(0.7))
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                            }
                        }
                    }
                    .padding(.top, 4)
                }
                
                Group {
                    if notesStorage.isLoading && notesStorage.notes.isEmpty {
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
            }
            .keyboardDoneButton()
            .onAppear {
                notesStorage.loadNotes()
            }
        }
        .overlay(
            // Меню поиска пользователей
            Group {
                if showUserFilterMenu {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation {
                                    showUserFilterMenu = false
                                    userSearchText = ""
                                }
                            }
                        
                        VStack(spacing: 0) {
                            // Поиск в меню
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(Color.adaptiveText(colorScheme: colorScheme).opacity(0.6))
                                TextField("Поиск автора", text: $userSearchText)
                                    .foregroundColor(Color.adaptiveText(colorScheme: colorScheme))
                                    .submitLabel(.return)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(Color.adaptiveInputBackground(colorScheme: colorScheme))
                            .cornerRadius(12)
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            
                            // Список пользователей
                            ScrollView {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(filteredUsers, id: \.self) { user in
                                    Button {
                                        withAnimation {
                                            if selectedUsers.contains(user) {
                                                selectedUsers.remove(user)
                                            } else {
                                                selectedUsers.insert(user)
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Image(systemName: selectedUsers.contains(user) ? "checkmark.circle.fill" : "circle")
                                                .font(.system(size: 16))
                                                .foregroundColor(selectedUsers.contains(user) ? .blue : Color.adaptiveText(colorScheme: colorScheme).opacity(0.5))
                                            Text(user)
                                                .font(.system(size: 15))
                                                .foregroundColor(Color.adaptiveText(colorScheme: colorScheme))
                                            Spacer()
                                        }
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 16)
                                    }
                                        
                                        if user != filteredUsers.last {
                                            Divider()
                                                .padding(.leading, 16)
                                        }
                                    }
                                    
                                    if filteredUsers.isEmpty {
                                        Text("Автор не найден")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color.adaptiveText(colorScheme: colorScheme).opacity(0.6))
                                            .padding(.vertical, 20)
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                            }
                            .frame(maxHeight: 300)
                            .background(Color.adaptiveInputBackground(colorScheme: colorScheme))
                            .cornerRadius(12)
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                            .padding(.bottom, 16)
                        }
                        .background(Color.adaptiveBackground(colorScheme: colorScheme))
                        .cornerRadius(16)
                        .shadow(radius: 20)
                        .padding(.horizontal, 32)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
            }
        )
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

