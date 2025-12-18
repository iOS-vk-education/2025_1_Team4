//
//  Note.swift
//  NoteHub
//
//  Created by Polina Sitnikova on 17.11.2025.
//

import Foundation
import SwiftUI
import Combine

struct DBNote: Identifiable {
    let nid: String
    let title: String
    let color: Color
    let isPublished: Bool
    let owner: DBUser
    let content: [DBNoteContentItem]
    let createdAt: Date
    
    var id: String { nid }
    var preview: String {
        content.compactMap {
            if case let .text(_, value) = $0 { value } else { nil }
        }
        .first ?? ""
    }
}
