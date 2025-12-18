//
//  KeyboardToolbar.swift
//  NoteHub
//
//  Created for keyboard "Готово" button
//

import SwiftUI
import UIKit

// Универсальный модификатор для добавления кнопки "Готово" на клавиатуре
struct KeyboardDoneButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Готово") {
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil,
                            from: nil,
                            for: nil
                        )
                    }
                    .foregroundColor(.blue)
                    .fontWeight(.medium)
                }
            }
    }
}

extension View {
    /// Добавляет кнопку "Готово" на клавиатуре для всех полей ввода
    func keyboardDoneButton() -> some View {
        modifier(KeyboardDoneButton())
    }
}
