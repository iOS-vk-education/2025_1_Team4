//
//  UserStorage.swift
//  NoteHub
//
//  Created by Tolepbek Temirlan on 20.11.2025.
//

import Foundation
import Combine

final class UserStorage: ObservableObject {
    @Published var name: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var userToken: String = ""
    
    func login(as name: String) {
        self.name = name
        userToken = UUID().uuidString
        isLoggedIn = true
    }
    
    func logout() {
        name = ""
        userToken = ""
        isLoggedIn = false
    }
}

