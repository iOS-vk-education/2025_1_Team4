import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var userStorage: UserStorage
    @EnvironmentObject private var notesStorage: NotesStorage

    @State private var showSettings = false

    private var username: String {
        userStorage.currentUser?.name ?? "Гость"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if notesStorage.notes.isEmpty {
                    EmptyProfileView(
                        username: username,
                        showSettings: $showSettings
                    )
                } else {
                    ProfileWithNotesView(
                        username: username,
                        notes: notesStorage.notes,
                        showSettings: $showSettings,
                        notesCount: notesStorage.notes.count,
                        publishedCount: notesStorage.publishedCount
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

