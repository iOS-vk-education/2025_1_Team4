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
        isValidEmail(login) &&
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
    @FocusState private var focusedField: Field?
    
    @State private var newEmailError: String?
    @State private var nameError: String?
    @State private var newPasswordError: String?
    @State private var repeatPasswordError: String?
    
    enum Field {
        case login, name, password, confirmPassword
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("Main_Background")
                    .ignoresSafeArea()
                    .onTapGesture {
                        focusedField = nil
                    }
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 32) {
                        Text("Укажите данные")
                            .font(.title2.bold())
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Почта")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                TextFieldWithError(
                                    title: "example@mail.ru",
                                    text: $viewModel.login,
                                    isSecure: false,
                                    errorText: newEmailError
                                )
                                .focused($focusedField, equals: .login)
                                .submitLabel(.return)
                                .onChange(of: viewModel.login) { _, newValue in
                                    let email = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                                    
                                    if email.isEmpty {
                                        newEmailError = "Введите почту"
                                    } else if !isValidEmail(email) {
                                        newEmailError = "Некорректная почта"
                                    } else {
                                        newEmailError = nil
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Имя")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                TextFieldWithError(
                                    title: "Иван Иванов",
                                    text: $viewModel.name,
                                    isSecure: false,
                                    errorText: nameError
                                )
                                .focused($focusedField, equals: .name)
                                .submitLabel(.return)
                                .onChange(of: viewModel.name) { _, newValue in
                                    let name = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                                    nameError = name.isEmpty ? "Имя не может быть пустым" : nil
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Пароль")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                TextFieldWithError(
                                    title: "Введите пароль",
                                    text: $viewModel.password,
                                    isSecure: true,
                                    errorText: newPasswordError
                                )
                                .focused($focusedField, equals: .password)
                                .submitLabel(.return)
                                .onChange(of: viewModel.password) { _, newValue in
                                    if newValue.count < 6 {
                                        newPasswordError = "Пароль слишком короткий"
                                    } else {
                                        newPasswordError = nil
                                    }
                                    
                                    if !viewModel.confirmPassword.isEmpty {
                                        repeatPasswordError =
                                        newValue == viewModel.confirmPassword
                                        ? nil
                                        : "Пароли не совпадают"
                                    }
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Повторите пароль")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                TextFieldWithError(
                                    title: "Повторите пароль",
                                    text: $viewModel.confirmPassword,
                                    isSecure: true,
                                    errorText: repeatPasswordError
                                )
                                .focused($focusedField, equals: .confirmPassword)
                                .submitLabel(.return)
                                .onChange(of: viewModel.confirmPassword) { _, newValue in
                                    repeatPasswordError =
                                    newValue == viewModel.password
                                    ? nil
                                    : "Пароли не совпадают"
                                }
                            }
                        }
                            Button {
                                register()
                            } label: {
                                Text("Зарегистрироваться")
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
                .keyboardDoneButton()
                .navigationBarHidden(true)
            }
            .fullScreenCover(isPresented: $isAuthPresented) {
                AuthView()
                    .environmentObject(userStorage)
            }
    }
    
    private func register() {
        userStorage.register(viewModel: viewModel) { error in
            guard let error else {
                dismiss()
                return
            }

            let mapped = AuthErrorMapper.map(error)

            newEmailError = mapped.email
            newPasswordError = mapped.password
            repeatPasswordError = mapped.password
        }
    }
}

func isValidEmail(_ s: String) -> Bool {
    let s = s.trimmingCharacters(in: .whitespacesAndNewlines)
    guard let at = s.firstIndex(of: "@") else { return false }
    let domain = s[s.index(after: at)...]
    return !s.isEmpty && domain.contains(".") && !s.contains(" ")
}

#Preview {
    RegistrationView()
        .environmentObject(UserStorage())
}
