//
//  SFColors.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import SwiftUI

/// Расширение Color с точными значениями из CSS-переменных index.html
extension Color {
    /// Безопасный инициализатор из HEX (#RGB, #RRGGBB, #RRGGBBAA)
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // Основные акцентные цвета (соответствуют tailwind/css из index.html)
    static let accent   = Color(hex: "#10b981") // Эмеральд (норма)
    static let danger   = Color(hex: "#ef4444") // Красный (авария)
    static let warning  = Color(hex: "#f59e0b") // Янтарный (предупреждение)
    
    // Поверхность и текст для тёмной темы
    static let darkBg       = Color(hex: "#0f172a")
    static let darkSurface  = Color(hex: "#1e293b")
    static let textPrimary  = Color(hex: "#f8fafc")
    static let textSecondary= Color(hex: "#94a3b8")
    static let glassBorder  = Color(hex: "#334155")
}