//
//  AuthErrorMapper.swift
//  NoteHub
//
//  Created by Валиуллина Иделия on 20.12.2025.
//


import Foundation

struct AuthFieldError: Error {
    let email: String?
    let password: String?
    let general: String?

    init(email: String? = nil, password: String? = nil, general: String? = nil) {
        self.email = email
        self.password = password
        self.general = general
    }
}

enum AuthErrorMapper {

    private static let firebaseAuthDomain = "FIRAuthErrorDomain"
    private static let firAuthNameKey = "FIRAuthErrorUserInfoNameKey"

    static func map(_ error: Error) -> AuthFieldError {
        let ns = error as NSError

        guard ns.domain == firebaseAuthDomain else {
            return AuthFieldError(general: ns.localizedDescription)
        }

        let name = ns.userInfo[firAuthNameKey] as? String

        if let name {
            switch name {
            case "ERROR_EMAIL_ALREADY_IN_USE":
                return AuthFieldError(email: "Почта уже зарегистрирована")
            case "ERROR_USER_NOT_FOUND":
                return AuthFieldError(email: "Почта ещё не зарегистрирована")
            case "ERROR_WRONG_PASSWORD":
                return AuthFieldError(password: "Неправильный пароль")
            case "ERROR_INVALID_EMAIL":
                return AuthFieldError(email: "Некорректная почта")
            case "ERROR_WEAK_PASSWORD":
                return AuthFieldError(password: "Пароль слишком слабый")
            case "ERROR_NETWORK_REQUEST_FAILED":
                return AuthFieldError(general: "Нет соединения с интернетом")
            case "ERROR_TOO_MANY_REQUESTS":
                return AuthFieldError(general: "Слишком много попыток. Попробуйте позже.")
            case "ERROR_INVALID_CREDENTIAL":
                return AuthFieldError(password: "Неверная почта или пароль")
            default:
                break
            }
        }

        switch ns.code {
        case 17007: // emailAlreadyInUse
            return AuthFieldError(email: "Почта уже зарегистрирована")

        case 17011: // userNotFound
            return AuthFieldError(email: "Почта ещё не зарегистрирована")

        case 17009: // wrongPassword
            return AuthFieldError(password: "Неправильный пароль")

        case 17008: // invalidEmail
            return AuthFieldError(email: "Некорректная почта")

        case 17026: // weakPassword
            return AuthFieldError(password: "Пароль слишком слабый")

        case 17020: // networkError
            return AuthFieldError(general: "Нет соединения с интернетом")

        case 17010: // tooManyRequests
            return AuthFieldError(general: "Слишком много попыток. Попробуйте позже.")

        case 17004: // invalidCredential (твой кейс)
            return AuthFieldError(password: "Неверная почта или пароль")

        default:
            // Фоллбек — системный текст
            return AuthFieldError(general: ns.localizedDescription)
        }
    }
}
