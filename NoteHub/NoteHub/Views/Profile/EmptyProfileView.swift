import SwiftUI

struct EmptyProfileView: View {
    let username: String
    @Binding var showSettings: Bool
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color("Main_Background")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                ProfileHeaderView(
                    username: username,
                    notesCount: 0,
                    publishedCount: 0,
                    showSettings: $showSettings
                    // showsFilter = false - иконки фильтра нет
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
            }
            .padding(.horizontal, 40)
        }
    }
}

#Preview {
    EmptyProfileView(username: "demo", showSettings: .constant(false))
}
