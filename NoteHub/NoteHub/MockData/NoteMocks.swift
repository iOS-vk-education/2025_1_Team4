//
//  NoteMocks.swift
//  NoteHub
//
//  Created by Evgeniy Pavlov on 19.11.2025.
//

import Foundation
import SwiftUI

class NoteMocks {
    static let notes: [DBNote] = [
        DBNote(
            nid: UUID().uuidString,
            title: "Математическая логика. Лекция 1",
            color: Color("Green_Background"),
            isPublished: true,
            owner: DBUser(uid: UUID().uuidString, email: "testEmail", name: "testName"),
            content: [
                .text(ncid: UUID().uuidString, value: "Определение (Модель Крипки). Рассмотрим Wi множество миров, имеющие частичный порядок (≤)."),
                .text(ncid: UUID().uuidString, value: "Зададим отношение вынужденности Wi ⊨ Pi (⊨ Wi x Pi)"),
                .text(ncid: UUID().uuidString, value: "При этом если Wj ⊨ Pi и Wj <= Wk, то Wk ⊨ Pi"),
                .text(ncid: UUID().uuidString, value: "Доопределим отношение вынужденности: "),
                .text(ncid: UUID().uuidString, value: "1. Wi ⊨ α&β, если Wi  α и Wi ⊨ β"),
                .text(ncid: UUID().uuidString, value: "2. Wi ⊨ a ∨ b, если Wi ⊨ а или Wi ⊨ b"),
                .text(ncid: UUID().uuidString, value: "3. Wi  ⊨ ¬α, если нет Wj > Wi таких, что Wj ⊨ α"),
                .text(ncid: UUID().uuidString, value: "Пусть во всех 𝑊𝑗 >= 𝑊𝑖 всегда, когда Wj ⊨ α, имеет место Wj ⊨ b, тогда в мире 𝑊𝑖 вынуждена импликация из a в b"),
                .text(ncid: UUID().uuidString, value: "Определение"),
                .text(ncid: UUID().uuidString, value: "Если Wi  ⊨ α при всех мирах из W, то a общезначима"),
            ],
        )
    ]
}
