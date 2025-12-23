//
//  ResetPasswordView.swift
//  NoteHub
//
//  Created by Валиуллина Иделия on 20.12.2025.
//

import SwiftUI

struct ResetPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var step: Step = .enterEmail
    
    @State private var email: String = ""
    @State private var code: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    @State private var emailError: String?
    @State private var codeError: String?
    @State private var passwordError: String?
    @State private var newPasswordError: String?
    @State private var repeatPasswordError: String?
    
    let origin: ResetPasswordOrigin
    
    enum ResetPasswordOrigin {
        case auth
        case settings
    }
    
    enum Step {
        case enterEmail
        case setPassword
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("Main_Background")
                    .ignoresSafeArea()
                    .onTapGesture { hideKeyboard() }
                
                VStack(spacing: 0) {
                    HStack(spacing: 8) {
                        Button(action: onBack) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 17, weight: .semibold))
                                Text("Вернуться")
                                    .font(.system(size: 17))
                            }
                        }
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        
                        Spacer()
                    }
                    .padding(.top, 4)
                    .padding(.horizontal, 16)
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 32) {
                        switch step {
                        case .enterEmail:
                            VStack(spacing: 16) {
                                Text("Введите почту")
                                    .font(.title2.bold())
                                    .frame(maxWidth: .infinity, alignment: .center)
                                
                                Text("Мы направим Вам письмо\nдля восстановления пароля")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                
                                TextFieldWithError(
                                    title: "example@mail.ru",
                                    text: $email,
                                    isSecure: false,
                                    errorText: emailError
                                )
                                .onChange(of: email) { _, newValue in
                                    let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                                    
                                    if trimmed.isEmpty {
                                        emailError = "Введите почту"
                                    } else if !isValidEmail(trimmed) {
                                        emailError = "Некорректная почта"
                                    } else {
                                        emailError = nil
                                    }
                                }
                            }
                            
                            Button {
                                Task {
                                    do {
                                        try await AuthManager.instance.sendPasswordResetEmail(to: email)
                                    } catch {
                                        print("Send recover email error: \(error)")
                                    }
                                }
                                step = .setPassword
                            } label: {
                                Text("Отправить письмо")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .foregroundStyle(.white)
                                    .font(.headline)
                            }
                            
                        case .setPassword:
                            VStack(spacing: 16) {
                                Text("Отправили вам письмо с ссылкой для смены пароля на почту")
                                    .font(.title2.bold())
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            
                            Button {
                                dismiss()
                            } label: {
                                Text("Продолжить")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .foregroundStyle(.white)
                                    .font(.headline)
                            }
                        }
                    }
                    .padding(.vertical, 32)
                    .padding(.horizontal, 16)
                    .background(Color("Modal_Background"))
                    .cornerRadius(16)
                    
                    Spacer()
                }
                .padding(32)
            }
            .keyboardDoneButton()
        }
    }
    
    private func onBack() {
        switch step {
        case .enterEmail:
            dismiss()
        case .setPassword:
            step = .enterEmail
        }
    }
    
    private var isPasswordValid: Bool {
        return password.count >= 6 && password == confirmPassword
    }
    
    private func validatePasswords() {
        if password.count < 6 {
            repeatPasswordError = "Пароль должен содержать минимум 6 символов"
        } else if !confirmPassword.isEmpty && password != confirmPassword {
            newPasswordError = "Пароли не совпадают"
        } else {
            passwordError = nil
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    ResetPasswordView(origin: .auth)
}
