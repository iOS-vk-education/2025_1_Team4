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
    
    func register(
        viewModel: RegistrationViewModel,
        completion: @escaping (Error?) -> Void
    ) {
        Task {
            do {
                let authData = try await AuthManager.instance.register(
                    email: viewModel.login,
                    password: viewModel.password
                )
                await MainActor.run {
                    self.authData = authData
                }
                
                let user = try await UserManager.instance.getUser(uid: authData.uid)
                
                await MainActor.run {
                    self.currentUser = user
                }
                
                completion(nil)
                
            } catch {
                print("test register us-4:\(error)")
                completion(error)
            }
        }
    }
    
    func login(
        viewModel: AuthViewModel,
        completion: @escaping (Error?) -> Void
    ) {
        Task {
            do {
                let authData = try await AuthManager.instance.logIn(
                    email: viewModel.login,
                    password: viewModel.password
                )
                await MainActor.run {
                    self.authData = authData
                }
                
                let user = try await UserManager.instance.getUser(uid: authData.uid)
                
                await MainActor.run {
                    self.currentUser = user
                }
                
                completion(nil)
                
            } catch {
                completion(error)
            }
        }
    }
        
        func updateUserName(newName: String) {
            Task {
                do {
                    currentUser = try await UserManager.instance.updateUserName(newName: newName)
                } catch {
                    // TODO same
                    print("Change name error: \(error)")
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
    

