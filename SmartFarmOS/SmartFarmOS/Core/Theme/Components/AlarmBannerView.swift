//
//  AlarmBannerView.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import SwiftUI

struct AlarmBannerView: View {
    @Binding var isActive: Bool
    @Binding var message: String
    
    var body: some View {
        VStack {
            if isActive {
                TimelineView(.animation) { _ in
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title2)
                            .foregroundStyle(.danger)
                            .symbolEffect(.variableColor.iterative, isActive: true)
                        
                        Text(message)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.danger)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.danger.opacity(0.6), lineWidth: 1.5)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.danger.opacity(pulseOpacity))
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isActive)
    }
    
    // Пульсация фона на основе таймлайна (плавная, без перерисовки всего view)
    private var pulseOpacity: Double {
        let t = Date().timeIntervalSinceReferenceDate
        return (sin(t * 3.5) + 1.0) * 0.12
    }
}

#Preview {
    struct Preview: View {
        @State var isActive = true
        @State var message = "⚠️ КРИТИЧЕСКАЯ ТЕМПЕРАТУРА ИЛИ ОБЕЗВОЖИВАНИЕ"
        var body: some View {
            VStack(spacing: 20) {
                AlarmBannerView(isActive: $isActive, message: $message)
                Toggle("Эмуляция тревоги", isOn: $isActive)
                    .padding()
            }
            .padding()
            .preferredColorScheme(.dark)
        }
    }
    Preview()
}