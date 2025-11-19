import SwiftUI

struct ProfileHeaderView: View {
    let username: String
    let notesCount: Int
    let publishedCount: Int
    @Binding var showSettings: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(username)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                Button(action: {
                    showSettings = true
                }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            HStack(spacing: 40) {
                VStack(spacing: 4) {
                    Text("\(notesCount)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                    Text("заметок")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                }
                
                VStack(spacing: 4) {
                    Text("\(publishedCount)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                    Text("публикаций")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
            .padding(.bottom, 20)
        }
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.black),
            alignment: .bottom
        )
    }
}

#Preview {
    ProfileHeaderView(
        username: "oleg2004",
        notesCount: 23,
        publishedCount: 9,
        showSettings: .constant(false)
    )
}
