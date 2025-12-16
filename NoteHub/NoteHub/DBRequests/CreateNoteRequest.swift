//
//  CreateNoteRequest.swift
//  NoteHub
//
//  Created by Evgeniy Pavlov on 09.12.2025.
//

import Foundation
import SwiftUI

struct CreateNoteRequest {
    let title: String
    let color: Color
    let isPublished: Bool
    let owner: DBUser
    let content: [CreateNoteContentItemRequest]
}
