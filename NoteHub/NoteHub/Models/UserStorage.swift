//
//  UserStorage.swift
//  NoteHub
//
//  Created by Tolepbek Temirlan on 20.11.2025.
//

import Foundation
import Combine

final class UserStorage: ObservableObject {
    @Published var currentUser: AuthDataResultModel?
    
    func loadUser() {
        self.currentUser = AuthManager.instance.getAuthenticatedUser()
    }
    
    func register(viewModel: RegistrationViewModel) {
        Task {
            do {
                currentUser = try await AuthManager.instance.register(email: viewModel.login, password: viewModel.password, name: viewModel.name)
                print("Registred new user: \(currentUser!)")
            } catch {
                // TODO может падать например из-за того что пользователь с таким email уже добавлен
                // надо как-то нормально это обрабатывать и доносить до пользака
                print("Registration error: \(error)")
            }
        }
    }
    
    func login(viewModel: AuthViewModel) {
        Task {
            do {
                currentUser = try await AuthManager.instance.logIn(email: viewModel.login, password: viewModel.password)
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
            currentUser = nil
        } catch {
            // TODO same
            print("Log out error: \(error)")
        }
    }
}

