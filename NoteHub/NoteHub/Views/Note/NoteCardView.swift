//
//  NoteCard.swift
//  NoteHub
//
//  Created by Polina Sitnikova on 17.11.2025.
//

import SwiftUI

struct NoteCardView: View {
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(note.title)
                    .font(.headline)
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 8)
            .background(note.color)
            .clipShape(RoundedCorner(radius: 12, corners: [.topLeft, .topRight]))
            
            Text(note.preview)
                .font(.subheadline)
                .lineLimit(2)
                .foregroundColor(.primary)
                .padding([.horizontal, .bottom], 8)
            
            if !note.userName.isEmpty {
                HStack {
                    Image(systemName: "person")
                        .foregroundColor(.gray)
                        .font(.footnote)
                    Text(note.userName)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    NoteCardView(note: NoteMocks.notes.first!)
}
