//
//  NotesStore.swift
//  NoteHub
//
//  Created by Polina Sitnikova on 17.11.2025.
//

import Foundation
import Combine

final class NotesStore: ObservableObject {
    @Published private(set) var notes: [Note]
    
    init(notes: [Note] = NoteMocks.notes) {
        self.notes = notes
    }
    
    var publishedCount: Int {
        notes.filter { $0.isPublished }.count
    }
    
    func addSample() {
        notes = NoteMocks.notes
    }
    
    func add(_ note: Note) {
        notes.insert(note, at: 0)
    }
    
    func replaceAll(with notes: [Note]) {
        self.notes = notes
    }
    
    func clearAll() {
        notes.removeAll()
    }
}
