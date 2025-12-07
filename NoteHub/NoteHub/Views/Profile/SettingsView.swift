import SwiftUI

// Маршруты внутри настроек
enum SettingsRoute: Hashable {
    case changeEmail
    case changeName
    case changePassword
}

// Типы алертов на главном экране
enum SettingsAlertType: Identifiable {
    case logout
    case delete
    
    var id: Int { hashValue }
}

// MARK: - Общие вспомогательные вью

/// Текстфилд с ошибкой и кнопкой показать/скрыть пароль
struct TextFieldWithError: View {
    let title: String
    @Binding var text: String
    let isSecure: Bool
    let errorText: String?
    
    @State private var isSecureVisible = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .trailing) {
                Group {
                    if isSecure && !isSecureVisible {
                        SecureField(title, text: $text)
                    } else {
                        TextField(title, text: $text)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            errorText == nil ? Color.gray.opacity(0.4) : Color.red,
                            lineWidth: 1
                        )
                )
                
                if isSecure {
                    Button {
                        isSecureVisible.toggle()
                    } label: {
                        Image(systemName: isSecureVisible ? "eye" : "eye.slash")
                            .foregroundColor(.gray)
                            .padding(.trailing, 12)
                    }
                }
            }
            
            if let errorText {
                Text(errorText)
                    .font(.system(size: 12))
                    .foregroundColor(.red)
            }
        }
    }
}

/// Общий фон и верхняя кнопка «Вернуться» для экранов изменения данных
struct SettingsFlowContainer<Content: View>: View {
    let onBack: () -> Void
    let content: () -> Content
    
    var body: some View {
        ZStack {
            Color("Main_Background")
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                HStack(spacing: 8) {
                    Button(action: onBack) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 17, weight: .semibold))
                            Text("Вернуться")
                                .font(.system(size: 17))
                        }
                    }
                    .foregroundColor(.black)
                    
                    Spacer()
                }
                .padding(.top, 8)
                
                Text("Укажите данные")
                    .font(.system(size: 20, weight: .semibold))
                    .padding(.top, 8)
                
                content()
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Экраны изменения данных

struct ChangeEmailView: View {
    let currentEmail: String
    let onBack: () -> Void
    
    @State private var enteredCurrentEmail = ""
    @State private var newEmail = ""
    @State private var password = ""
    
    @State private var currentEmailError: String?
    @State private var newEmailError: String?
    @State private var passwordError: String?
    
    var body: some View {
        SettingsFlowContainer(onBack: onBack) {
            VStack(spacing: 16) {
                VStack(spacing: 12) {
                    TextFieldWithError(
                        title: "Текущая почта",
                        text: $enteredCurrentEmail,
                        isSecure: false,
                        errorText: currentEmailError
                    )
                    
                    TextFieldWithError(
                        title: "Новая почта",
                        text: $newEmail,
                        isSecure: false,
                        errorText: newEmailError
                    )
                    
                    TextFieldWithError(
                        title: "Пароль",
                        text: $password,
                        isSecure: true,
                        errorText: passwordError
                    )
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
                
                Button(action: handleChangeEmail) {
                    Text("Изменить почту")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                Button {
                    // TODO: забыли пароль
                } label: {
                    Text("Забыли пароль?")
                        .font(.system(size: 15))
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    private func handleChangeEmail() {
        currentEmailError = nil
        newEmailError = nil
        passwordError = nil
        
        var valid = true
        
        if enteredCurrentEmail.lowercased() != currentEmail.lowercased() || enteredCurrentEmail.isEmpty {
            currentEmailError = "Некорректный логин"
            valid = false
        }
        
        if !newEmail.contains("@") || !newEmail.contains(".") {
            newEmailError = "Некорректная почта"
            valid = false
        }
        
        if password.count < 6 {
            passwordError = "Неправильный пароль"
            valid = false
        }
        
        if valid {
            // TODO: запрос на изменение почты
            onBack()
        }
    }
}

struct ChangeNameView: View {
    let currentName: String
    let onBack: () -> Void
    
    @State private var newName = ""
    @State private var password = ""
    
    @State private var nameError: String?
    @State private var passwordError: String?
    
    var body: some View {
        SettingsFlowContainer(onBack: onBack) {
            VStack(spacing: 16) {
                VStack(spacing: 12) {
                    TextFieldWithError(
                        title: "Новое имя",
                        text: $newName,
                        isSecure: false,
                        errorText: nameError
                    )
                    
                    TextFieldWithError(
                        title: "Пароль",
                        text: $password,
                        isSecure: true,
                        errorText: passwordError
                    )
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
                
                Button(action: handleChangeName) {
                    Text("Изменить имя")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                Button {
                    // TODO: забыли пароль
                } label: {
                    Text("Забыли пароль?")
                        .font(.system(size: 15))
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    private func handleChangeName() {
        nameError = nil
        passwordError = nil
        
        var valid = true
        
        if newName.trimmingCharacters(in: .whitespaces).isEmpty {
            nameError = "Имя не может быть пустым"
            valid = false
        }
        
        if password.count < 6 {
            passwordError = "Неправильный пароль"
            valid = false
        }
        
        if valid {
            // TODO: запрос на изменение имени
            onBack()
        }
    }
}

struct ChangePasswordView: View {
    let onBack: () -> Void
    
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var repeatPassword = ""
    
    @State private var currentPasswordError: String?
    @State private var newPasswordError: String?
    @State private var repeatPasswordError: String?
    
    var body: some View {
        SettingsFlowContainer(onBack: onBack) {
            VStack(spacing: 16) {
                VStack(spacing: 12) {
                    TextFieldWithError(
                        title: "Текущий пароль",
                        text: $currentPassword,
                        isSecure: true,
                        errorText: currentPasswordError
                    )
                    
                    TextFieldWithError(
                        title: "Новый пароль",
                        text: $newPassword,
                        isSecure: true,
                        errorText: newPasswordError
                    )
                    
                    TextFieldWithError(
                        title: "Повторите пароль",
                        text: $repeatPassword,
                        isSecure: true,
                        errorText: repeatPasswordError
                    )
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
                
                Button(action: handleChangePassword) {
                    Text("Изменить пароль")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                Button {
                    // TODO: забыли пароль
                } label: {
                    Text("Забыли пароль?")
                        .font(.system(size: 15))
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    private func handleChangePassword() {
        currentPasswordError = nil
        newPasswordError = nil
        repeatPasswordError = nil
        
        var valid = true
        
        if currentPassword.count < 6 {
            currentPasswordError = "Неправильный пароль"
            valid = false
        }
        
        if newPassword.count < 6 {
            newPasswordError = "Пароль слишком короткий"
            valid = false
        }
        
        if newPassword != repeatPassword {
            repeatPasswordError = "Пароли не совпадают"
            valid = false
        }
        
        if valid {
            // TODO: запрос на изменение пароля
            onBack()
        }
    }
}

// MARK: - Главный экран настроек

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userStorage: UserStorage
    
    @State private var path = NavigationPath()
    @State private var activeAlert: SettingsAlertType?
    
    private var username: String {
        userStorage.currentUser?.name ?? "Гость"
    }
    
    private var email: String {
        userStorage.currentUser?.email ?? "—"
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            mainScreen
                .navigationDestination(for: SettingsRoute.self) { route in
                    switch route {
                    case .changeEmail:
                        ChangeEmailView(
                            currentEmail: email,
                            onBack: { path.removeLast() }
                        )
                    case .changeName:
                        ChangeNameView(
                            currentName: username,
                            onBack: { path.removeLast() }
                        )
                    case .changePassword:
                        ChangePasswordView(
                            onBack: { path.removeLast() }
                        )
                    }
                }
        }
        .alert(item: $activeAlert) { alertType in
            switch alertType {
            case .logout:
                return Alert(
                    title: Text("Выход из аккаунта"),
                    message: Text("Вы уверены, что хотите выйти из аккаунта \(email)?"),
                    primaryButton: .cancel(Text("Отмена")),
                    secondaryButton: .destructive(Text("Выйти")) {
                        // TODO: userStorage.logout()
                        dismiss()
                    }
                )
            case .delete:
                return Alert(
                    title: Text("Удаление аккаунта"),
                    message: Text("Все созданные заметки будут безвозвратно удалены.\nВы уверены, что хотите удалить аккаунт \(email)?"),
                    primaryButton: .cancel(Text("Отмена")),
                    secondaryButton: .destructive(Text("Удалить")) {
                        // TODO: userStorage.deleteAccount()
                        dismiss()
                    }
                )
            }
        }
    }
    
    private var mainScreen: some View {
        ZStack {
            Color("Main_Background")
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {
                // Верх: кнопка "Вернуться"
                HStack(spacing: 8) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 17, weight: .semibold))
                            Text("Вернуться")
                                .font(.system(size: 17))
                        }
                    }
                    .foregroundColor(.black)
                    
                    Spacer()
                }
                .padding(.top, 8)
                
                // Карточка пользователя (на всю ширину)
                VStack(alignment: .leading, spacing: 6) {
                    Text(username)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text("Почта: \(email)")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                    
                    Text("Имя: \(username)")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
                .frame(maxWidth: .infinity)     // почти на всю ширину экрана
                
                // Карточка действий
                VStack(spacing: 0) {
                    settingsRow(title: "Изменить почту") {
                        path.append(SettingsRoute.changeEmail)
                    }
                    
                    Divider()
                    
                    settingsRow(title: "Изменить имя") {
                        path.append(SettingsRoute.changeName)
                    }
                    
                    Divider()
                    
                    settingsRow(title: "Изменить пароль") {
                        path.append(SettingsRoute.changePassword)
                    }
                    
                    Divider()
                    
                    settingsRow(title: "Выйти", textColor: .red) {
                        activeAlert = .logout
                    }
                    
                    Divider()
                    
                    settingsRow(title: "Удалить аккаунт", textColor: .red) {
                        activeAlert = .delete
                    }
                }
                .background(Color.white)
                .cornerRadius(16)
                .frame(maxWidth: .infinity)
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
    }
    
    private func settingsRow(
        title: String,
        textColor: Color = .blue,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 17))
                    .foregroundColor(textColor)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(UserStorage())
}

