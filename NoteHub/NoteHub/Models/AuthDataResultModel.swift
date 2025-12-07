//
//  AuthDataResultModel.swift
//  NoteHub
//
//  Created by Evgeniy Pavlov on 06.12.2025.
//

import Foundation
import FirebaseAuth

struct AuthDataResultModel {
    let uid: String
    let email: String
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email!
    }
}
