//
//  RegistrationView.swift
//  NoteHub
//
//  Created by Валиуллина Иделия on 14.11.2025.
//

import SwiftUI
import Combine

class RegistrationViewModel: ObservableObject {
    @Published var login: String = ""
    @Published var name: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    var isFormValid: Bool {
        !login.isEmpty &&
        !name.isEmpty &&
        !password.isEmpty &&
        !confirmPassword.isEmpty &&
        password == confirmPassword
    }
}

struct RegistrationView: View {
    @StateObject private var viewModel = RegistrationViewModel()
    @State private var isAuthPresented = false
    @EnvironmentObject private var userStorage: UserStorage
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color("Main_Background")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(alignment: .leading, spacing: 32) {
                    Text("Укажите данные")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Логин")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("example@mail.ru", text: $viewModel.login)
                                .textFieldStyle(AppTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Имя")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("Иван Иванов", text: $viewModel.name)
                                .textFieldStyle(AppTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Пароль")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            SecureField("Введите пароль", text: $viewModel.password)
                                .textFieldStyle(AppTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Повторите пароль")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            SecureField("Повторите пароль", text: $viewModel.confirmPassword)
                                .textFieldStyle(AppTextFieldStyle())
                        }
                    }
                    
                    Button {
                        register()
                    } label: {
                        Text("Войти")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(viewModel.isFormValid ? Color.blue : Color.secondary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .foregroundStyle(.white)
                            .font(.headline)
                    }
                    .disabled(!viewModel.isFormValid)
                    
                }
                .padding(.vertical, 32)
                .padding(.horizontal, 16)
                .background(Color("Modal_Background"))
                .cornerRadius(16)
                
                Spacer()
                
                VStack(spacing: 8) {
                    Text("Уже есть аккаунт?")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Button {
                        isAuthPresented = true
                    } label: {
                        Text("Войти")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(32)
            
        }
        .fullScreenCover(isPresented: $isAuthPresented) {
            AuthView()
                .environmentObject(userStorage)
        }
    }
    
    private func register() {
        userStorage.login(as: viewModel.name.isEmpty ? viewModel.login : viewModel.name)
        dismiss()
    }
}

#Preview {
    RegistrationView()
        .environmentObject(UserStorage())
}
