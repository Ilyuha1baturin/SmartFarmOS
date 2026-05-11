//
//  AIChatView.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import SwiftUI

struct AIChatView: View {
    @State private var input = ""
    @State private var messages: [String] = ["👋 Привет! Я ИИ-ассистент SmartFarmOS. Спрашивай про микроклимат, профили выращивания или состояние устройств."]
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(messages, id: \.self) { msg in
                    HStack {
                        Text(msg)
                            .padding()
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                        Spacer()
                    }.padding(.horizontal)
                }
            }
            HStack {
                TextField("Спросить ИИ...", text: $input)
                    .textFieldStyle(.roundedBorder)
                Button("Отправить") {
                    messages.append("🤔 Анализирую...")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        messages.append("✅ Запрос обработан. (Интеграция с API в разработке)")
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("ИИ-ассистент")
        .background(Color(.systemBackground))
    }
}