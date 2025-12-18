//
//  NotesStorage.swift
//  NoteHub
//
//  Created by Evgeniy Pavlov on 11.12.2025.
//

import Foundation
import Combine

class NotesStorage: ObservableObject {
    @Published var notes: [DBNote] = []
    @Published var isLoading: Bool = false
    
    func loadNotes() {
        guard !isLoading else { return }
        isLoading = true
        Task {
            do {
                let loadedNotes = try await NotesManager.instance.getAllNotes()
                await MainActor.run {
                    self.notes = loadedNotes
                    self.isLoading = false
                    print("Notes loaded: \(loadedNotes.count)")
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    print("Load notes error: \(error)")
                }
            }
        }
    }
    
    var publishedCount: Int {
        notes.filter { $0.isPublished }.count
    }
}
