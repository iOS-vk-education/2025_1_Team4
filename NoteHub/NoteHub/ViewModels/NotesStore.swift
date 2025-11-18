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
        notes = [
            Note(
                title: "Алгоритмы и структуры данных",
                excerpt: "Амортизационный анализ (англ. amortized analysis) — метод подсчёта времени, требуемого для выполнения последовательности операций над структурой данных. При",
                isPublished: true
            ),
            Note(
                title: "Персистентные структуры данных",
                excerpt: "Персистентные структуры данных (англ. persistent data structure) — это структуры данных, которые при внесении в них каких-то изменений сохраняют все свои предыдущие сост...",
                isPublished: false
            )
        ]
    }
    
    func clearAll() { notes.removeAll() }
}
