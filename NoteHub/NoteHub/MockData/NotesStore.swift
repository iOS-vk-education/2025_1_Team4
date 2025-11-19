//
//  NotesStore.swift
//  NoteHub
//
//  Created by Polina Sitnikova on 17.11.2025.
//

import Foundation
import Combine

final class NotesStore: ObservableObject {
    @Published var notes: [Note] = []
    
    var publishedCount: Int {
        notes.filter { $0.isPublished }.count
    }
    
    func addSample() {
        notes = NoteMocks.notes
    }
    
    func clearAll() { notes.removeAll() }
}
