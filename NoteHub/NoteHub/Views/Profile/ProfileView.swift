import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var userStorage: UserStorage
    @EnvironmentObject private var notesStorage: NotesStorage

    @State private var showSettings = false

    private var username: String {
        userStorage.currentUser?.name ?? "Гость"
    }

    // Заметки текущего пользователя
    private var userNotes: [DBNote] {
        notesStorage.notes.filter { $0.owner.name == username }
    }
    
    // Количество заметок текущего пользователя
    private var userNotesCount: Int {
        userNotes.count
    }
    
    // Количество опубликованных заметок текущего пользователя
    private var userPublishedCount: Int {
        userNotes.filter { $0.isPublished }.count
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if userNotes.isEmpty {
                    EmptyProfileView(
                        username: username,
                        showSettings: $showSettings
                    )
                } else {
                    ProfileWithNotesView(
                        username: username,
                        notes: userNotes,
                        showSettings: $showSettings,
                        notesCount: userNotesCount,
                        publishedCount: userPublishedCount
                    )
                }
            }
            .onAppear {
                notesStorage.loadNotes()
            }
        }
        .fullScreenCover(isPresented: $showSettings) {
            SettingsView()
                .interactiveDismissDisabled()
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(NotesStorage())
        .environmentObject(UserStorage())
}

