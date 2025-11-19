//
//  SearchView.swift
//  NoteHub
//
//  Created by Evgeniy Pavlov on 19.11.2025.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    var body: some View {
        HStack {
            TextField("Поиск", text: $searchText)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    HStack {
                        Spacer()
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(.systemGray3))
                            .padding(.trailing, 14)
                    }
                )
        }
        .padding(.horizontal, 32)
        .padding(.top, 8)
    }
}

#Preview {
    @Previewable @State var text = ""
    return SearchBarView(searchText: $text)
}
