import SwiftUI

struct ProfileHeaderView: View {
    let username: String
    let notes: [DBNote]
    @Binding var showSettings: Bool

    private var notesCount: Int {
        notes.filter { $0.owner.name == username }.count
    }

    private var publishedCount: Int {
        notes.filter { $0.isPublished && $0.owner.name == username }.count
    }

    let showsFilter: Bool
    let isFilterActive: Bool
    let filterTitle: String?
    var onFilterTap: (() -> Void)?
    var onClearFilterTap: (() -> Void)?

    init(
        username: String,
        notes: [DBNote],
        showSettings: Binding<Bool>,
        showsFilter: Bool = false,
        isFilterActive: Bool = false,
        filterTitle: String? = nil,
        onFilterTap: (() -> Void)? = nil,
        onClearFilterTap: (() -> Void)? = nil
    ) {
        self.username = username
        self.notes = notes
        self._showSettings = showSettings
        self.showsFilter = showsFilter
        self.isFilterActive = isFilterActive
        self.filterTitle = filterTitle
        self.onFilterTap = onFilterTap
        self.onClearFilterTap = onClearFilterTap
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            //имя + настройки
            HStack {
                Text(username)
                    .font(.system(size: 22, weight: .semibold))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(
                        Capsule().fill(Color.white)
                    )

                Spacer()

                Button { showSettings = true } label: {
                    Image(systemName: "gearshape")
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                }
            }

            //Статистика и фильтр
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

            //Чип выбранного фильтра
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
                        Capsule().fill(Color.white)
                    )
                }
            }
        }
        .padding(16)
        .background(Color("Main_Background"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    //Чип статистики
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

//Кнопка фильтра
private struct FilterIconButton: View {
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image("Filter_Icon")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .foregroundColor(.black)
        }
        .buttonStyle(FilterButtonStyle(isActive: isActive))
    }
}

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
            return configurationIsPressed(isPressed)
        } else {
            return isPressed ? Color.black.opacity(0.12) : Color.clear
        }
    }

    private func configurationIsPressed(_ isPressed: Bool) -> Color {
        isPressed
            ? Color.black.opacity(0.24)
            : Color.black.opacity(0.16)
    }
}

#Preview {
    ProfileHeaderView(
        username: "petrpetrov",
        notes: [],
        showSettings: .constant(false),
        showsFilter: true,
        isFilterActive: true,
        filterTitle: "только опубликованные"
    )
}

