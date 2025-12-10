//
//  CreateNoteContentItemRequest.swift
//  NoteHub
//
//  Created by Evgeniy Pavlov on 10.12.2025.
//

import Foundation

enum CreateNoteContentItemRequest {
    case text(value: String)
    case image(createImageRequest: CreateImageRequest)
}
