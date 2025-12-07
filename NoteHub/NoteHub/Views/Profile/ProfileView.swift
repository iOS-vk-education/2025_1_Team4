import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var store: NotesStore
    @EnvironmentObject private var userStorage: UserStorage
    @State private var showSettings = false

    private var username: String {
        userStorage.currentUser?.name ?? "Гость"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if store.notes.isEmpty {
                    EmptyProfileView(
                        username: username,
                        showSettings: $showSettings
                    )
                } else {
                    ProfileWithNotesView(
                        username: username,
                        notes: store.notes,
                        showSettings: $showSettings,
                        notesCount: store.notes.count,
                        publishedCount: store.publishedCount
                    )
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(userStorage)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(NotesStore())
        .environmentObject(UserStorage())
}

