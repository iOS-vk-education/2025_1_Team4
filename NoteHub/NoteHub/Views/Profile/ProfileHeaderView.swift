import SwiftUI

struct ProfileHeaderView: View {
    let username: String
    let notesCount: Int
    let publishedCount: Int
    
    @Binding var showSettings: Bool
    
    /// Показывать ли иконку фильтра
    let showsFilter: Bool
    /// Активен ли фильтр (иконка подсвечена)
    let isFilterActive: Bool
    /// Текст выбранного фильтра для чипа (или nil если фильтр не выбран)
    let filterTitle: String?
    
    /// Тап по иконке фильтра
    var onFilterTap: (() -> Void)?
    /// Тап по кресту в чипе
    var onClearFilterTap: (() -> Void)?
    
    init(
        username: String,
        notesCount: Int,
        publishedCount: Int,
        showSettings: Binding<Bool>,
        showsFilter: Bool = false,
        isFilterActive: Bool = false,
        filterTitle: String? = nil,
        onFilterTap: (() -> Void)? = nil,
        onClearFilterTap: (() -> Void)? = nil
    ) {
        self.username = username
        self.notesCount = notesCount
        self.publishedCount = publishedCount
        self._showSettings = showSettings
        self.showsFilter = showsFilter
        self.isFilterActive = isFilterActive
        self.filterTitle = filterTitle
        self.onFilterTap = onFilterTap
        self.onClearFilterTap = onClearFilterTap
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // MARK: - Верхняя строка: имя + настройки
            HStack {
                Text(username)
                    .font(.system(size: 22, weight: .semibold))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(
                        Capsule()
                            .fill(Color.white)
                    )
                
                Spacer()
                
                Button { showSettings = true } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                }
            }
            
            // MARK: - Статистика и иконка фильтра
            HStack(spacing: 10) {
                statChip(title: "\(notesCount)", subtitle: "заметок")
                statChip(title: "\(publishedCount)", subtitle: "публикаций")
                
                Spacer()
                
                if showsFilter {
                    FilterIconButton(
                        isActive: isFilterActive,
                        action: { onFilterTap?() }
                    )
                    .offset(x: 4)
                }
            }
            
            // MARK: - Чип выбранного фильтра
            if let filterTitle = filterTitle, !filterTitle.isEmpty {
                HStack {
                    Spacer()
                    HStack(spacing: 6) {
                        Text(filterTitle)
                            .font(.system(size: 13))
                        
                        Button {
                            onClearFilterTap?()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 11, weight: .bold))
                        }
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 10)
                    .background(
                        Capsule()
                            .fill(Color.white)
                    )
                }
            }
        }
        .padding(16)
        .background(Color("Main_Background"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
    
    // MARK: - Чип статистики
    private func statChip(title: String, subtitle: String) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
            Text(subtitle)
                .font(.system(size: 14))
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(
            Capsule().fill(Color.white)
        )
        .foregroundColor(.black)
    }
}

// MARK: - Кнопка-воронка

/// Отдельная кнопка фильтра, чтобы контролировать размер, выравнивание и состояния
private struct FilterIconButton: View {
    let isActive: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button {
            action()
        } label: {
            Image("Filter_Icon")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .foregroundColor(
                    isActive ? .black : .black
                )
        }
        .buttonStyle(FilterButtonStyle(isActive: isActive))
    }
}

/// ButtonStyle, чтобы затемнять фон при нажатии и при активном фильтре
private struct FilterButtonStyle: ButtonStyle {
    let isActive: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(backgroundColor(isPressed: configuration.isPressed))
            )
    }
    
    private func backgroundColor(isPressed: Bool) -> Color {
        if isActive {
            // активный фильтр: тёмный фон, при нажатии ещё чуть темнее
            return isPressed
                ? Color.black.opacity(0.24)
                : Color.black.opacity(0.16)
        } else {
            // неактивный: без фона, при тапе лёгкая подсветка
            return isPressed
                ? Color.black.opacity(0.12)
                : Color.clear
        }
    }
}

#Preview {
    ProfileHeaderView(
        username: "petrpetrov",
        notesCount: 12,
        publishedCount: 7,
        showSettings: .constant(false),
        showsFilter: true,
        isFilterActive: true,
        filterTitle: "только опубликованные",
        onFilterTap: {},
        onClearFilterTap: {}
    )
}

