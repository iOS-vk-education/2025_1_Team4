//
//  SearchView.swift
//  NoteHub
//
//  Created by Evgeniy Pavlov on 19.11.2025.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    @FocusState.Binding var isFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    private var placeholderColor: Color {
        colorScheme == .dark ? Color.gray.opacity(0.6) : Color(.systemGray3)
    }
    
    private var backgroundColor: Color {
        Color.adaptiveInputBackground(colorScheme: colorScheme)
    }
    
    var body: some View {
        HStack {
            TextField("Поиск", text: $searchText)
                .focused($isFocused)
                .foregroundColor(Color.adaptiveText(colorScheme: colorScheme))
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    HStack {
                        Spacer()
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(placeholderColor)
                            .padding(.trailing, 14)
                    }
                )
                .submitLabel(.return)
        }
        .padding(.horizontal, 32)
        .padding(.top, 8)
    }
}

#Preview {
    @Previewable @State var text = ""
    @Previewable @FocusState var isFocused: Bool
    return SearchBarView(searchText: $text, isFocused: $isFocused)
}
