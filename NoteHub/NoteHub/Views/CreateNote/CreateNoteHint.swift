import SwiftUI

extension CreateNoteView {
    var hintPopover: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Подсказка")
                .font(.headline)
            Text("""
Используйте Markdown:
`#`  — заголовки
`*…*` — курсив
`-`  — списки
`1)` — нумерация
""")
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            Button("Понятно") {
                showHint = false
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

