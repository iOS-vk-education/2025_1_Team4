//
//  EmptyProfileView.swift
//  NoteHub
//
//  Created by Polina Sitnikova on 17.11.2025.
//

import SwiftUI

struct EmptyProfileView: View {
    @Binding var showSettings: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ProfileHeaderView(
                username: "petrpetrov",
                notesCount: 0,
                publishedCount: 0,
                showSettings: $showSettings
            )
            
            Spacer()
            
            VStack(spacing: 8) {
                Text("Тут пока пусто")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                
                Text("Создайте свою первую заметку!")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            CustomTabBar(activeTab: .profile)
        }
        .background(Color(red: 0.95, green: 0.97, blue: 1.0))
    }
}
