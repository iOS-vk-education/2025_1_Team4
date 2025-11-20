//
//  NoteContentItem.swift
//  NoteHub
//
//  Created by Evgeniy Pavlov on 19.11.2025.
//

import Foundation

enum NoteContentItem: Identifiable, Equatable {
    case text(id: UUID = UUID(), value: String)
    case image(id: UUID = UUID(), resource: ImageResource)
    
    enum ImageResource: Equatable {
        case asset(name: String)
        case data(Data)
    }
    
    var id: UUID {
        switch self {
        case .text(let id, _), .image(let id, _):
            return id
        }
    }
}
