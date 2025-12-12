//
//  FullscreenImageView.swift
//  NoteHub
//
//  Created by Evgeniy Pavlov on 18.11.2025.
//

import SwiftUI

struct FullscreenImageView: View {
    let uiImage: UIImage
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { dismiss() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .regular))
                        Text("Вернуться")
                            .font(.system(size: 18))
                    }
                }
                .foregroundColor(.white)
                Spacer()
            }
            .padding(.top, 16)
            .padding(.leading, 16)

            Spacer()
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .background(Color.black)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Spacer()
        }
        .background(Color.black.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}

#Preview {
    NavigationStack {
        FullscreenImageView(uiImage: UIImage(named: "Cat_Image")!)
    }
}
