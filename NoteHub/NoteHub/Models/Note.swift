//
//  Note.swift
//  NoteHub
//
//  Created by Polina Sitnikova on 17.11.2025.
//

import Foundation
import SwiftUI

struct Note: Identifiable {
    let id = UUID()
    let title: String
    let content: [NoteContentItem]
    let color: Color
    let isPublished: Bool
    let userName: String
    
    var preview: String {
            content.compactMap {
                if case let .text(text) = $0 { text } else { nil }
            }
            .first ?? ""
        }
}
