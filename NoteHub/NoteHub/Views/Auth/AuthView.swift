//
//  AuthView.swift
//  NoteHub
//
//  Created by Валиуллина Иделия on 14.11.2025.
//

import SwiftUI
import Combine

class AuthViewModel: ObservableObject {
    @Published var login: String = ""
    @Published var password: String = ""

    var isFormValid: Bool {
        return isValidEmail(login) && password.count >= 6
    }
}

struct AuthView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var isRegistrationPresented = false
    @State private var isResetPasswordPresented = false
    @EnvironmentObject private var userStorage: UserStorage
    @FocusState private var focusedField: Field?
    
    @State private var currentEmailError: String?
    @State private var passwordError: String?
    
    enum Field {
        case login, password
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
                                    errorText: currentEmailError
                                )
                                .focused($focusedField, equals: .login)
                                .submitLabel(.return)
                                .onChange(of: viewModel.login) { _, newValue in
                                    let email = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                                    
                                    if email.isEmpty {
                                        currentEmailError = "Введите почту"
                                    } else if !(email.contains("@") && email.contains(".") && !email.contains(" ")) {
                                        currentEmailError = "Некорректная почта"
                                    } else {
                                        currentEmailError = nil
                                    }
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
                                    errorText: passwordError
                                )
                                .focused($focusedField, equals: .password)
                                .submitLabel(.return)
                                .onChange(of: viewModel.password) { _, newValue in
                                    if newValue.isEmpty {
                                        passwordError = "Введите пароль"
                                    } else if newValue.count < 6 {
                                        passwordError = "Неправильный пароль"
                                    } else {
                                        passwordError = nil
                                    }
                                }
                                
                            }
                        }

                        Button {
                            login()
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
                    
                    VStack() {
                        Button {
                            isResetPasswordPresented = true
                        } label: {
                            Text("Забыли пароль?")
                                .font(.system(size: 15))
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                        }
                    }.padding(.vertical, 16)
                    
                    
                    Spacer()

                    VStack(spacing: 8) {
                        Text("Еще нет аккаунта?")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)

                        Button {
                            isRegistrationPresented = true
                        } label: {
                            Text("Зарегистрироваться")
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
        .fullScreenCover(isPresented: $isResetPasswordPresented) {
            ResetPasswordView(origin: .auth)
                .environmentObject(userStorage)
        }
        .fullScreenCover(isPresented: $isRegistrationPresented) {
            RegistrationView()
                .environmentObject(userStorage)
        }
    }

    private func login() {
        userStorage.login(viewModel: viewModel) { error in
            guard let error else { return }

            let mapped = AuthErrorMapper.map(error)

            currentEmailError = mapped.email
            passwordError = mapped.password
        }
    }

}

#Preview {
    AuthView()
        .environmentObject(UserStorage())
}
