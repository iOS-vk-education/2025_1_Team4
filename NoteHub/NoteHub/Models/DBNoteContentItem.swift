//
//  NoteContentItem.swift
//  NoteHub
//
//  Created by Evgeniy Pavlov on 19.11.2025.
//

import Foundation

enum DBNoteContentItem: Identifiable{
    case text(ncid: String, value: String)
    case image(ncid: String, image: DBImage)

    var id: String { ncid }
    var ncid: String {
        switch self {
        case .text(let ncid, _), .image(let ncid, _):
            return ncid
        }
    }
}
