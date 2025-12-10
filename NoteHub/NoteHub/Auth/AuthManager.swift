//
//  AuthManager.swift
//  NoteHub
//
//  Created by Evgeniy Pavlov on 06.12.2025.
//

import Foundation
import FirebaseAuth

final class AuthManager {
    static let instance = AuthManager()
    private init() {}
    
    func register(email: String, password: String) async throws -> AuthDataResultModel {
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authResult.user)
    }
    
    func getAuthenticatedUser() -> AuthDataResultModel? {
        guard let user = Auth.auth().currentUser else {
            return nil
        }
        return AuthDataResultModel(user: user)
    }
    
    func logIn(email: String, password: String) async throws -> AuthDataResultModel {
        
        let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authResult.user)
    }
    
    func logOut() throws {
        try Auth.auth().signOut()
    }
    
    func updatePassword(newPassword: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        try await user.updatePassword(to: newPassword)
    }
    
    func updateEmail(newEmail: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        try await user.updateEmail(to: newEmail)
    }
    
    func delete() async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        try await user.delete()
    }
}
