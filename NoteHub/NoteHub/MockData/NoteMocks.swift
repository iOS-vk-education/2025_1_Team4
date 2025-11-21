//
//  NoteMocks.swift
//  NoteHub
//
//  Created by Evgeniy Pavlov on 19.11.2025.
//

import Foundation
import SwiftUI

class NoteMocks {
    static let notes: [Note] = [
        Note(
            title: "Математическая логика. Лекция 1",
            content: [
                .text(value: "Определение (Модель Крипки). Рассмотрим Wi множество миров, имеющие частичный порядок (≤)."),
                .text(value: "Зададим отношение вынужденности Wi ⊨ Pi (⊨ Wi x Pi)"),
                .text(value: "При этом если Wj ⊨ Pi и Wj <= Wk, то Wk ⊨ Pi"),
                .image(resource: .asset(name: "Cat_Image")),
                .text(value: "Доопределим отношение вынужденности: "),
                .text(value: "1. Wi ⊨ α&β, если Wi  α и Wi ⊨ β"),
                .text(value: "2. Wi ⊨ a ∨ b, если Wi ⊨ а или Wi ⊨ b"),
                .text(value: "3. Wi  ⊨ ¬α, если нет Wj > Wi таких, что Wj ⊨ α"),
                .text(value: "Пусть во всех 𝑊𝑗 >= 𝑊𝑖 всегда, когда Wj ⊨ α, имеет место Wj ⊨ b, тогда в мире 𝑊𝑖 вынуждена импликация из a в b"),
                .image(resource: .asset(name: "Cat_Image")),
                .text(value: "Определение"),
                .text(value: "Если Wi  ⊨ α при всех мирах из W, то a общезначима"),
                .image(resource: .asset(name: "Cat_Image")),
            ],
            color: Color(red: 119/255, green: 178/255, blue: 179/255),
            isPublished: true,
            userName: "oleg2004",
        ),
        Note(
            title: "Дискретная математика. Лекция 1",
            content: [
                .text(value: "Определение: Множество — первичное математическое понятие..."),
                .image(resource: .asset(name: "Cat_Image")),
                .text(value: "Здесь идут рассуждения, примеры, задачи...")
            ],
            color: Color(red: 250/255, green: 218/255, blue: 221/255),
            isPublished: false,
            userName: "YavaLasha",
        ),
        Note(
            title: "Операционные системы. Введение.",
            content: [
                .text(value: "Зачем нужна операционная система? Что такое вычислительный узел?"),
                .image(resource: .asset(name: "Cat_Image")),
            ],
            color: Color(red: 250/255, green: 226/255, blue: 189/255),
            isPublished: true,
            userName: "testName",
        ),
        Note(
            title: "Математическая логика. Лекция 1",
            content: [
                .text(value: "Определение (Модель Крипки). Рассмотрим Wi множество миров, имеющие частичный порядок (≤)."),
                .image(resource: .asset(name: "Cat_Image")),
                .text(value: "Доопределим отношение вынужденности: 1. Wi ⊨ α&β, если Wi ⊨ α и Wi ⊨ β..."),
                .image(resource: .asset(name: "Cat_Image")),
                .image(resource: .asset(name: "Cat_Image")),
            ],
            color: Color(red: 119/255, green: 178/255, blue: 179/255),
            isPublished: true,
            userName: "oleg2004",
        ),
        Note(
            title: "Дискретная математика. Лекция 1",
            content: [
                .text(value: "Определение: Множество — первичное математическое понятие..."),
                .image(resource: .asset(name: "Cat_Image")),
                .text(value: "Здесь идут рассуждения, примеры, задачи...")
            ],
            color: Color(red: 250/255, green: 218/255, blue: 221/255),
            isPublished: false,
            userName: "YavaLasha",
        ),
        Note(
            title: "Операционные системы. Введение.",
            content: [
                .text(value: "Зачем нужна операционная система? Что такое вычислительный узел?"),
                .image(resource: .asset(name: "Cat_Image")),
            ],
            color: Color(red: 250/255, green: 226/255, blue: 189/255),
            isPublished: true,
            userName: "testName",
        ),
        Note(
            title: "Математическая логика. Лекция 1",
            content: [
                .text(value: "Определение (Модель Крипки). Рассмотрим Wi множество миров, имеющие частичный порядок (≤)."),
                .image(resource: .asset(name: "Cat_Image")),
                .text(value: "Доопределим отношение вынужденности: 1. Wi ⊨ α&β, если Wi ⊨ α и Wi ⊨ β..."),
                .image(resource: .asset(name: "Cat_Image")),
                .image(resource: .asset(name: "Cat_Image")),
            ],
            color: Color(red: 119/255, green: 178/255, blue: 179/255),
            isPublished: true,
            userName: "oleg2004",
        ),
        Note(
            title: "Дискретная математика. Лекция 1",
            content: [
                .text(value: "Определение: Множество — первичное математическое понятие..."),
                .image(resource: .asset(name: "Cat_Image")),
                .text(value: "Здесь идут рассуждения, примеры, задачи...")
            ],
            color: Color(red: 250/255, green: 218/255, blue: 221/255),
            isPublished: false,
            userName: "YavaLasha",
        ),
        Note(
            title: "Операционные системы. Введение.",
            content: [
                .text(value: "Зачем нужна операционная система? Что такое вычислительный узел?"),
                .image(resource: .asset(name: "Cat_Image")),
            ],
            color: Color(red: 250/255, green: 226/255, blue: 189/255),
            isPublished: true,
            userName: "testName",
        ),
    ]
}
