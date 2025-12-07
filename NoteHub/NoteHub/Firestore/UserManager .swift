//
//  UserManager .swift
//  NoteHub
//
//  Created by Evgeniy Pavlov on 07.12.2025.
//

import Foundation
import FirebaseFirestore

final class UserManager {
    static let instance = UserManager()
    private init() {}
    
    func createUser(uid: String, email: String, name: String) async throws -> DBUser {
        let dbUser = DBUser(uid: uid, email: email, name: name)
        let dict = dbUser.toDictionary()
        try await Firestore.firestore().collection("users").document(uid).setData(dict, merge: false)
        return dbUser
    }
    
    func getUser(uid: String) async throws -> DBUser {
        let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
        guard let dict = snapshot.data() else {
            throw URLError(.badServerResponse)
        }
        guard let dbUser = DBUser(dict: dict) else {
            throw URLError(.badServerResponse)
        }
        return dbUser
    }
    
    func deleteUser(uid: String) async throws {
        try await Firestore.firestore().collection("users").document(uid).delete()
    }
}
