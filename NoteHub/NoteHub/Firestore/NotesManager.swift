//
//  NotesManager.swift
//  NoteHub
//
//  Created by Evgeniy Pavlov on 10.12.2025.
//

import Foundation
import SwiftUI
import UIColorHexSwift
import FirebaseFirestore

final class NotesManager {
    static let instance = NotesManager()
    private init() {}
    
    func createNote(createNoteRequest: CreateNoteRequest) async throws -> DBNote {
        let nid = UUID().uuidString
        let dbContent = try await processContent(content: createNoteRequest.content)
        
        let dict: [String: Any] = [
            "nid": nid,
            "title": createNoteRequest.title,
            "color": UIColor(createNoteRequest.color).hexString(),
            "isPublished": createNoteRequest.isPublished,
            "uid": createNoteRequest.owner.uid,
            "content": dbContent.map { dbNoteContentItem in
                switch(dbNoteContentItem) {
                case .text(ncid: let ncid, value: _):
                    ["ncid": ncid, "type": "text"] as [String: Any]
                case .image(ncid: let ncid, image: _):
                    ["ncid": ncid, "type": "image"] as [String: Any]
                }
            }
        ]
        
        try await Firestore.firestore().collection("notes").document(nid).setData(dict, merge: false)
        return DBNote(
            nid: nid,
            title: createNoteRequest.title,
            color: createNoteRequest.color,
            isPublished: createNoteRequest.isPublished,
            owner: createNoteRequest.owner,
            content: dbContent,
        )
    }
    
    private func processContent(content: [CreateNoteContentItemRequest]) async throws -> [DBNoteContentItem] {
        try await withThrowingTaskGroup(of: DBNoteContentItem.self) { group in
            for item in content {
                group.addTask {
                    return try await NoteContentItemManager.instance.createNoteContentItem(createNoteContentItemRequest: item)
                }
            }
            
            var result: [DBNoteContentItem] = []
            for try await dbNoteContentItem in group {
                result.append(dbNoteContentItem)
            }
            return result
        }
    }
    
    func getAllNotes() async throws -> [DBNote] {
        let snapshot = try await Firestore.firestore().collection("notes").getDocuments()
        let documents = snapshot.documents
        return try await withThrowingTaskGroup(of: DBNote.self) { group in
            for document in documents {
                group.addTask {
                    let dict = document.data()
                    guard let content = dict["content"] as? [[String: String]] else { throw URLError(.badServerResponse) }
                    var contents: [DBNoteContentItem] = []
                    for contentItem in content {
                        guard let ncid = contentItem["ncid"], let type = contentItem["type"] else { throw URLError(.badServerResponse) }
                        switch type {
                        case "text":
                            let item = try await NoteContentItemManager.instance.getNoteContentItemText(ncid: ncid)
                            contents.append(item)
                        case "image":
                            let item = try await NoteContentItemManager.instance.getNoteContentItemImage(ncid: ncid)
                            contents.append(item)
                        default:
                            throw URLError(.badServerResponse)
                        }
                    }
                    
                    guard let nid = dict["nid"] as? String,
                          let title = dict["title"] as? String,
                          let colorString = dict["color"] as? String,
                          let isPublished = dict["isPublished"] as? Bool,
                          let uid = dict["uid"] as? String else { throw URLError(.badServerResponse) }
                    
                    let color = Color(UIColor(colorString))
                    let dbUser = try await UserManager.instance.getUser(uid: uid)
                    
                    return DBNote(
                        nid: nid,
                        title: title,
                        color: color,
                        isPublished: isPublished,
                        owner: dbUser,
                        content: contents
                    )
                }
            }
            
            var results: [DBNote] = []
            for try await result in group {
                results.append(result)
            }
            return results
        }
    }
}
