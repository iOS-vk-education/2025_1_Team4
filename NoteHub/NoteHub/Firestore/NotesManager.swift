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
        
        var dict: [String: Any] = [
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
        
        let createdAt = Timestamp(date: Date())
        dict["createdAt"] = createdAt
        try await Firestore.firestore().collection("notes").document(nid).setData(dict, merge: false)
        return DBNote(
            nid: nid,
            title: createNoteRequest.title,
            color: createNoteRequest.color,
            isPublished: createNoteRequest.isPublished,
            owner: createNoteRequest.owner,
            content: dbContent,
            createdAt: Date()
        )
    }
    
    private func processContent(content: [CreateNoteContentItemRequest]) async throws -> [DBNoteContentItem] {
        try await withThrowingTaskGroup(of: (Int, DBNoteContentItem).self) { group in
            for (index, item) in content.enumerated() {
                group.addTask {
                    let dbItem = try await NoteContentItemManager.instance.createNoteContentItem(createNoteContentItemRequest: item)
                    return (index, dbItem)
                }
            }
            
            var results: [(Int, DBNoteContentItem)] = []
            for try await result in group {
                results.append(result)
            }
            // Сортируем по индексу, чтобы сохранить порядок
            results.sort { $0.0 < $1.0 }
            return results.map { $0.1 }
        }
    }
    
    func getAllNotes() async throws -> [DBNote] {
        let snapshot = try await Firestore.firestore().collection("notes").getDocuments()
        let documents = snapshot.documents
        
        // Сначала собираем все уникальные UID для параллельной загрузки пользователей
        let uids = Set(documents.compactMap { $0.data()["uid"] as? String })
        
        // Параллельно загружаем всех пользователей
        var userCache: [String: DBUser] = [:]
        try await withThrowingTaskGroup(of: (String, DBUser).self) { userGroup in
            for uid in uids {
                userGroup.addTask {
                    let user = try await UserManager.instance.getUser(uid: uid)
                    return (uid, user)
                }
            }
            
            for try await (uid, user) in userGroup {
                userCache[uid] = user
            }
        }
        
        // Теперь загружаем заметки параллельно, используя кэш пользователей
        return try await withThrowingTaskGroup(of: DBNote.self) { group in
            for document in documents {
                group.addTask {
                    let dict = document.data()
                    guard let content = dict["content"] as? [[String: String]] else { throw URLError(.badServerResponse) }
                    
                    // Параллельная загрузка всех элементов контента
                    let contents = try await withThrowingTaskGroup(of: (Int, DBNoteContentItem).self) { contentGroup in
                        for (index, contentItem) in content.enumerated() {
                            contentGroup.addTask {
                                guard let ncid = contentItem["ncid"], let type = contentItem["type"] else {
                                    throw URLError(.badServerResponse)
                                }
                                let item: DBNoteContentItem
                                switch type {
                                case "text":
                                    item = try await NoteContentItemManager.instance.getNoteContentItemText(ncid: ncid)
                                case "image":
                                    item = try await NoteContentItemManager.instance.getNoteContentItemImage(ncid: ncid)
                                default:
                                    throw URLError(.badServerResponse)
                                }
                                return (index, item)
                            }
                        }
                        
                        var results: [(Int, DBNoteContentItem)] = []
                        for try await result in contentGroup {
                            results.append(result)
                        }
                        // Сортируем по индексу, чтобы сохранить порядок
                        results.sort { $0.0 < $1.0 }
                        return results.map { $0.1 }
                    }
                    
                    guard let nid = dict["nid"] as? String,
                          let title = dict["title"] as? String,
                          let colorString = dict["color"] as? String,
                          let isPublished = dict["isPublished"] as? Bool,
                          let uid = dict["uid"] as? String else { throw URLError(.badServerResponse) }
                    
                    let color = Color(UIColor(colorString))
                    
                    // Используем предзагруженный кэш пользователей
                    guard let dbUser = userCache[uid] else {
                        throw URLError(.badServerResponse)
                    }
                    
                    // Используем timestamp из Firestore документа для сортировки по дате
                    let createdAt: Date
                    if let timestamp = document.data()["createdAt"] as? Timestamp {
                        createdAt = timestamp.dateValue()
                    } else {
                        // Если createdAt нет в данных, используем текущую дату
                        // (для старых документов, созданных до добавления поля createdAt)
                        createdAt = Date()
                    }
                    
                    return DBNote(
                        nid: nid,
                        title: title,
                        color: color,
                        isPublished: isPublished,
                        owner: dbUser,
                        content: contents,
                        createdAt: createdAt
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
    
    func deleteNote(nid: String) async throws {
        try await Firestore.firestore().collection("notes").document(nid).delete()
    }
    
    func unpublishNote(nid: String) async throws {
        try await Firestore.firestore().collection("notes").document(nid).updateData([
            "isPublished": false
        ])
    }
}
