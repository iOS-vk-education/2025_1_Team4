//
//  WelcomeView.swift
//  NoteHub
//
//  Created by Валиуллина Иделия on 15.11.2025.
//


import SwiftUI

struct WelcomeView: View {
    @State private var isActive = false
    
    var body: some View {
        Group {
            if isActive {
                AuthView()
            } else {
                ZStack {
                    Color("Main_Background")
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Image("LOGO")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                       
                        Text("Добро пожаловать\nв NoteHub!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isActive = true
                }
            }
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(UserStorage())
}
