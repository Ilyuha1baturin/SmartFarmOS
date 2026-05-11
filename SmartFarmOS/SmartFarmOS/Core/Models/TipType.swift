//
//  TipType.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import Foundation

/// Тип совета — соответствует типам из emergency.json / calendar.json
public enum TipType: String, Codable, CaseIterable {
    case calendar   // календарный совет по возрасту
    case species    // породный совет
    case info       // общий/ротационный совет
    case emergency  // экстренное уведомление (из AlarmEngine)
}

/// Совет для пользователя — аналог структур из main.cpp
public struct Tip: Identifiable, Equatable, Codable {
    public let id: UUID
    public let day: Int               // день жизни птицы
    public let text: String           // текст совета
    public let type: TipType
    public let timestamp: Date?       // для emergency/info
    
    public init(id: UUID = UUID(), day: Int, text: String, type: TipType, timestamp: Date? = nil) {
        self.id = id; self.day = day; self.text = text; self.type = type; self.timestamp = timestamp
    }
    
    /// Для JSON-совместимости с веб-панелью
    public func toJSON() -> [String: Any] {
        ["id": id.uuidString, "day": day, "text": text, "type": type.rawValue, "timestamp": timestamp?.timeIntervalSince1970]
    }
}