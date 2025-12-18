//
//  NoteCard.swift
//  NoteHub
//
//  Created by Polina Sitnikova on 17.11.2025.
//

import SwiftUI
import MarkdownUI

struct NoteCardView: View {
    let note: DBNote
    @Environment(\.colorScheme) private var colorScheme
    
    private var textColor: Color {
        Color.adaptiveText(colorScheme: colorScheme)
    }
    
    private var backgroundColor: Color {
        Color.adaptiveBackground(colorScheme: colorScheme)
    }
    
    private var gradientColor: Color {
        Color.adaptiveGradient(colorScheme: colorScheme)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(note.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(colorScheme == .dark ? .black : textColor)
                Spacer()
                if !note.isPublished {
                    Text("Черновик")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            colorScheme == .dark 
                                ? Color.orange 
                                : Color.orange.opacity(0.9)
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color.orange.opacity(0.3), radius: 2, x: 0, y: 1)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
            .background(note.color)
            .clipShape(RoundedCorner(radius: 12, corners: [.topLeft, .topRight]))
            
            ZStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 0) {
                    Markdown(sanitizeMarkdown(note.preview))
                        .markdownTheme(.docC)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.clear)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
                
                LinearGradient(
                    colors: [
                        gradientColor.opacity(0),
                        gradientColor.opacity(0.9)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 24)
            }
            .frame(maxHeight: 140, alignment: .top)
            .clipped()
            
            if !note.owner.name.isEmpty {
                HStack {
                    Image(systemName: "person")
                        .foregroundColor(.gray)
                        .font(.footnote)
                    Text(note.owner.name)
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
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
