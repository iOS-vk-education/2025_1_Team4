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
    
    func loadNotes() {
        Task {
            do {
                try await self.notes = NotesManager.instance.getAllNotes()
                print("Notes loaded")
            } catch {
                print("Load notes error: \(error)")
            }
        }
    }
    
    var publishedCount: Int {
        notes.filter { $0.isPublished }.count
    }
}
