//
//  NotesStore.swift
//  NoteHub
//
//  Created by Polina Sitnikova on 17.11.2025.
//

import Foundation
import Combine

//final class NotesStore: ObservableObject {
//    @Published private(set) var notes: [DBNote]
//    
//    init(notes: [DBNote] = NoteMocks.notes) {
//        self.notes = notes
//    }
//    
//    var publishedCount: Int {
//        notes.filter { $0.isPublished }.count
//    }
//    
//    func addSample() {
//        notes = NoteMocks.notes
//    }
//    
//    func add(createNoteRequest: CreateNoteRequest) {
//        Task {
//            let dbNote = NotesManager.instance.createNote(createNoteRequest: createNoteRequest)
//            notes.insert(dbNote, at: 0)
//        }
//    }
//}
