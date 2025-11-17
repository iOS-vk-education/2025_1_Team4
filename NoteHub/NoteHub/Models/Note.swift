//
//  Note.swift
//  NoteHub
//
//  Created by Polina Sitnikova on 17.11.2025.
//

import Foundation

struct Note: Identifiable {
    let id = UUID()
    let title: String
    let excerpt: String
    let isPublished: Bool
}
