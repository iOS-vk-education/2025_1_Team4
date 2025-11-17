//
//  AppStyles.swift
//  NoteHub
//
//  Created by Валиуллина Иделия on 15.11.2025.
//

import SwiftUI


struct AppTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .frame(height: 50)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .font(.system(size: 16))
    }
}
