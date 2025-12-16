//
//  NoteContentItemManager.swift
//  NoteHub
//
//  Created by Evgeniy Pavlov on 10.12.2025.
//

import Foundation
import FirebaseFirestore

final class NoteContentItemManager {
    static let instance = NoteContentItemManager()
    private init() {}
    
    static let NOTE_TEXT_ITEMS = "note_text_items"
    static let NOTE_IMAGE_ITEMS = "note_image_items"
    
    func createNoteContentItem(createNoteContentItemRequest: CreateNoteContentItemRequest) async throws -> DBNoteContentItem {
        let ncid = UUID().uuidString
        switch createNoteContentItemRequest {
        case .text(value: let value):
            let dict: [String: Any] = [
                "ncid": ncid,
                "text": value,
            ]
            try await Firestore.firestore().collection(NoteContentItemManager.NOTE_TEXT_ITEMS).document(ncid).setData(dict, merge: false)
            return DBNoteContentItem.text(ncid: ncid, value: value)
        case .image(createImageRequest: let createImageRequest):
            let dbImage = try await ImageManager.instance.createImage(createimageRequest: createImageRequest)
            let dict: [String: Any] = [
                "ncid": ncid,
                "url": dbImage.url,
            ]
            try await Firestore.firestore().collection(NoteContentItemManager.NOTE_IMAGE_ITEMS).document(ncid).setData(dict, merge: false)
            return DBNoteContentItem.image(ncid: ncid, image: dbImage)
        }
    }
    
    func getNoteContentItemImage(ncid: String) async throws -> DBNoteContentItem {
        let snapshot = try await Firestore.firestore().collection(NoteContentItemManager.NOTE_IMAGE_ITEMS).document(ncid).getDocument()
        guard let dict = snapshot.data() else { throw URLError(.badServerResponse) }
        guard let url = dict["url"] as? String else { throw URLError(.badServerResponse) }
        
        let image = try await ImageManager.instance.getImage(urlString: url)
        return DBNoteContentItem.image(ncid: ncid, image: image)
    }
    
    func getNoteContentItemText(ncid: String) async throws -> DBNoteContentItem {
        let snapshot = try await Firestore.firestore().collection(NoteContentItemManager.NOTE_TEXT_ITEMS).document(ncid).getDocument()
        guard let dict = snapshot.data() else { throw URLError(.badServerResponse) }
        guard let text = dict["text"] as? String else { throw URLError(.badServerResponse) }
        
        return DBNoteContentItem.text(ncid: ncid, value: text)
    }
}
