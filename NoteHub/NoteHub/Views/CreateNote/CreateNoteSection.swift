//
//  CreateNoteSection.swift
//  NoteHub
//
//  Created by Tolepbek Temirlan on 20.11.2025.
//

import Foundation

struct NoteComposerSection: Identifiable, Equatable {
    enum Kind {
        case text
        case image
    }
    
    let id: UUID
    var kind: Kind
    var text: String
    var imageData: Data?
    
    init(id: UUID = UUID(), kind: Kind, text: String = "", imageData: Data? = nil) {
        self.id = id
        self.kind = kind
        self.text = text
        self.imageData = imageData
    }
    
    static func textSection() -> NoteComposerSection {
        NoteComposerSection(kind: .text, text: "")
    }
    
    static func imageSection() -> NoteComposerSection {
        NoteComposerSection(kind: .image)
    }
    
    var isEmpty: Bool {
        switch kind {
        case .text:
            return text.trimmed.isEmpty
        case .image:
            return imageData == nil
        }
    }
    
    func makeCreateContentItemRequest() -> CreateNoteContentItemRequest? {
        switch kind {
        case .text:
            let trimmed = text.trimmed
            return trimmed.isEmpty ? nil : .text(value: text)
        case .image:
            guard let data = imageData else { return nil }
            return .image(createImageRequest: CreateImageRequest(data: data))
        }
    }
}

extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

func sanitizeMarkdown(_ text: String) -> String {
    var sanitized = text
    let replacements: [(String, String)] = [
        (#"(?m)^(#{1,6})(\S)"#, "$1 $2"),
        (#"(?m)^(-)(\S)"#, "$1 $2"),
        (#"(?m)^(\d+\))(\S)"#, "$1 $2")
    ]
    
    for replacement in replacements {
        sanitized = sanitized.replacingOccurrences(
            of: replacement.0,
            with: replacement.1,
            options: .regularExpression
        )
    }
    return sanitized
}

#if canImport(UIKit)
import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

