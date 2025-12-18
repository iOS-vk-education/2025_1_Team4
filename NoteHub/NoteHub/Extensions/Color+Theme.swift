//
//  Color+Theme.swift
//  NoteHub
//
//  Created for dark mode support
//

import SwiftUI

extension Color {
    /// Адаптивный цвет текста (черный в светлой теме, белый в темной)
    static func adaptiveText(colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .white : .black
    }
    
    /// Адаптивный цвет фона (белый в светлой теме, темно-серый в темной)
    static func adaptiveBackground(colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0x2C/255.0, green: 0x2C/255.0, blue: 0x2C/255.0) : .white
    }
    
    /// Адаптивный цвет для градиента (белый в светлой теме, темный в темной)
    static func adaptiveGradient(colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0x2C/255.0, green: 0x2C/255.0, blue: 0x2C/255.0) : .white
    }
    
    /// Адаптивный цвет фона для инпутов (белый в светлой теме, темно-серый в темной)
    static func adaptiveInputBackground(colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(red: 0x2C/255.0, green: 0x2C/255.0, blue: 0x2C/255.0) : .white
    }
}

