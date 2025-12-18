import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var userStorage: UserStorage
    @EnvironmentObject private var notesStorage: NotesStorage
    @Environment(\.profileNavigationPath) var profileNavigationPath

    @State private var showSettings = false

    private var username: String {
        userStorage.currentUser?.name ?? "Гость"
    }

    // Заметки текущего пользователя, отсортированные по дате (сначала новые)
    private var userNotes: [DBNote] {
        notesStorage.notes
            .filter { $0.owner.name == username }
            .sorted { $0.createdAt > $1.createdAt }
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
        NavigationStack(path: profileNavigationPath) {
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

