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
        !login.isEmpty && !password.isEmpty
    }
}

struct AuthView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var isRegistrationPresented = false
    @EnvironmentObject private var userStorage: UserStorage

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
                            Text("Пароль")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            SecureField("Введите пароль", text: $viewModel.password)
                                .textFieldStyle(AppTextFieldStyle())
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
        // переход на регистрацию
        .fullScreenCover(isPresented: $isRegistrationPresented) {
            RegistrationView()
                .environmentObject(userStorage)
        }
    }

    private func login() {
        userStorage.login(as: viewModel.login)
    }

}

#Preview {
    AuthView()
        .environmentObject(UserStorage())
}
