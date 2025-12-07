//
//  UserStorage.swift
//  NoteHub
//
//  Created by Tolepbek Temirlan on 20.11.2025.
//

import Foundation
import Combine

final class UserStorage: ObservableObject {
    @Published var authData: AuthDataResultModel?
    @Published var currentUser: DBUser?
    
    func loadAuthData() {
        self.authData = AuthManager.instance.getAuthenticatedUser()
    }
    
    func loadCurrentUser() {
        if let uid = authData?.uid {
            Task {
                do {
                    try await self.currentUser = UserManager.instance.getUser(uid: uid)
                } catch {
                    print("Get user from db error: \(error)")
                }
            }
        }
    }
    
    func register(viewModel: RegistrationViewModel) {
        Task {
            do {
                authData = try await AuthManager.instance.register(email: viewModel.login, password: viewModel.password)
                currentUser = try await UserManager.instance.createUser(uid: authData!.uid, email: authData!.email, name: viewModel.name)
                print("Registred new user: \(currentUser!)")
            } catch {
                // TODO может падать например из-за того что пользователь с таким email уже добавлен
                // надо как-то нормально это обрабатывать и доносить до пользака
                
                // обнаружил что там могут падать разные ошибки
                // например пароль < 6 символов или некорректный email
                print("Registration error: \(error)")
            }
        }
    }
    
    func login(viewModel: AuthViewModel) {
        Task {
            do {
                authData = try await AuthManager.instance.logIn(email: viewModel.login, password: viewModel.password)
                currentUser = try await UserManager.instance.getUser(uid: authData!.uid)
                print("Logged user: \(currentUser!)")
            } catch {
                // TODO same
                print("LogIn error: \(error)")
            }
        }
    }
    
    func logout() {
        do {
            try AuthManager.instance.logOut()
            authData = nil
        } catch {
            // TODO same
            print("Log out error: \(error)")
        }
    }
    
    func delete() {
        Task {
            do {
                try await UserManager.instance.deleteUser(uid: authData!.uid)
                try await AuthManager.instance.delete()
                authData = nil
                currentUser = nil
            } catch {
                // TODO same
                print("Delete user error: \(error)")
            }
        }
    }
}

