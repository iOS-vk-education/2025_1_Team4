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
        case enterCode
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
                                // TODO: обработка ошибок, если почты не существует/не получается отправить письмо
                                step = .enterCode
                                
                            } label: {
                                Text("Отправить письмо")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .foregroundStyle(.white)
                                    .font(.headline)
                            }
                            
                        case .enterCode:
                            VStack(spacing: 16) {
                                Text("Введите код")
                                    .font(.title2.bold())
                                    .frame(maxWidth: .infinity, alignment: .center)
                                
                                Text("Введите код из письма, которое мы отправили Вам на почту\n\(email)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                TextFieldWithError(
                                    title: "XXX XXX",
                                    text: $code,
                                    isSecure: false,
                                    errorText: codeError
                                )
                            }
                            
                            Button {
                                // TODO: неправильный код
                                step = .setPassword
                                
                            } label: {
                                Text("Подтвердить")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .foregroundStyle(.white)
                                    .font(.headline)
                            }
                            
                        case .setPassword:
                            VStack(spacing: 16) {
                                Text("Придумайте новый пароль")
                                    .font(.title2.bold())
                                    .frame(maxWidth: .infinity, alignment: .center)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    
                                    Text("Пароль")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    TextFieldWithError(
                                        title: "",
                                        text: $password,
                                        isSecure: true,
                                        errorText:passwordError
                                    )
                                    .onChange(of: password) { oldValue, newValue in
                                        validatePasswords()
                                    }
                                    
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    
                                    Text("Повторите пароль")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    TextFieldWithError(
                                        title: "",
                                        text: $confirmPassword,
                                        isSecure: true,
                                        errorText: repeatPasswordError
                                    )
                                    .onChange(of: password) { oldValue, newValue in
                                        validatePasswords()
                                    }
                                    
                                }
                                
                            }
                            
                            Button {
                                changePassword()
                                dismiss()
                            } label: {
                                Text("Подтвердить")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .foregroundStyle(.white)
                                    .font(.headline)
                            }
                            .disabled(!isPasswordValid)
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
        case .enterCode:
            step = .enterEmail
        case .setPassword:
            step = .enterCode
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
    
    private func changePassword() {
        // TODO: логика изменения пароля в файр
    }
}

#Preview {
    ResetPasswordView(origin: .auth)
}
