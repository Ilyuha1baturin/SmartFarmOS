//
//  GlassCardModifier.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import SwiftUI

/// Модификатор "тёмное стекло" для карточек
struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 16
    var padding: CGFloat = 16
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.darkBg.opacity(0.65))
                    .overlay(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.glassBorder.opacity(0.35), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 4)
    }
}

extension View {
    /// Применяет стиль стеклянной карточки SmartFarmOS
    func glassCard(cornerRadius: CGFloat = 16, padding: CGFloat = 16) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius, padding: padding))
    }
}