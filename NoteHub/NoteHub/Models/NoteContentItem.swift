//
//  NoteContentItem.swift
//  NoteHub
//
//  Created by Evgeniy Pavlov on 19.11.2025.
//

import Foundation

enum NoteContentItem: Identifiable {
    case text(String)
    case image(String) // имя картинки

    var id: UUID {
        UUID()
    }
}
