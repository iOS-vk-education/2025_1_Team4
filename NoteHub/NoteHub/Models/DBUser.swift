//
//  DBUser.swift
//  NoteHub
//
//  Created by Evgeniy Pavlov on 07.12.2025.
//

import Foundation

struct DBUser {
    let uid: String
    let email: String
    let name: String
    
    init(uid: String, email: String, name: String) {
        self.uid = uid
        self.email = email
        self.name = name
    }
    
    init?(dict: [String: Any]) {
        guard let uid = dict["uid"] as? String,
              let email = dict["email"] as? String,
              let name = dict["name"] as? String else {
            return nil
        }
        self.uid = uid
        self.email = email
        self.name = name
    }

    func toDictionary() -> [String: Any] {
        return [
            "uid": uid,
            "email": email,
            "name": name,
        ]
    }
}
