//
//  SettingsView.swift
//  NoteHub
//
//  Created by Polina Sitnikova on 17.11.2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showDeleteAlert = false
    @State private var showLogoutAlert = false

    var body: some View {
        NavigationView {
            VStack {
                Spacer()

                VStack(spacing: 14) {
                    Button { showLogoutAlert = true } label: {
                        Text("Выйти")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color(red: 0.278, green: 0.275, blue: 0.275)))
                            .foregroundColor(.white)
                    }

                    Button { showDeleteAlert = true } label: {
                        Text("Удалить аккаунт")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).stroke(Color(red: 0.173, green: 0.173, blue: 0.173), lineWidth: 1))
                            .foregroundColor(Color(red: 0.173, green: 0.173, blue: 0.173))
                    }
                }
                .padding(.horizontal, 40)

                Spacer()
            }
            .navigationBarTitle("Настройки", displayMode: .inline)
            .navigationBarItems(leading: Button("Вернуться") { dismiss() })
            .alert("Удаление аккаунта", isPresented: $showDeleteAlert) {
                Button("Вернуться", role: .cancel) {}
                Button("Удалить", role: .destructive) {
                }
            } message: {
                Text("Все созданные заметки будут безвозвратно удалены. Вы уверены, что хотите удалить аккаунт petrpetrov@mail.ru?") //пока так потом из базы
            }
            .alert("Выход из аккаунта", isPresented: $showLogoutAlert) {
                Button("Вернуться", role: .cancel) {}
                Button("Выйти", role: .destructive) {
                }
            } message: {
                Text("Вы уверены, что хотите выйти из аккаунта petrpetrov@mail.ru?")//аналогично
            }
        }
    }
}

#Preview {
    SettingsView()
}
