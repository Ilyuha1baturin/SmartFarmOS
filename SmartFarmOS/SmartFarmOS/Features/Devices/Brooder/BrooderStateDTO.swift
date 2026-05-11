//
//  BrooderStateDTO.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import Foundation

struct BrooderStateDTO: Codable {
    let t: Double?      // Текущая температура (BME)
    let tt: Double?     // Целевая температура
    let h: Double?      // Текущая влажность
    let th: Int?        // Целевая влажность
    let l: Int?         // Освещённость (lux)
    let w: Bool?        // Вода OK
    let lid: Bool?      // Крышка закрыта
    let door: Bool?     // Дверь закрыта
    let p: Bool?        // Паническая тревога (аудио)
    let fan: Int?       // ШИМ вентилятора (0-255)
    let a: Bool?        // Активна ли общая тревога
    let mode: Bool?     // true = AUTO, false = MANUAL
    let age: Int?       // Возраст цыплят
    let ageOffset: Int? // Ручная корректировка возраста
    let breed: Int?     // Индекс породы (0-7)
    let co2: Int?       // CO₂ ppm
    let nh3: Int?       // ΔNH3 (разница от базовой)
    let iaq: Int?       // Индекс качества воздуха (0-100)
    let fanLimit: Int?  // Максимальный % вентилятора по возрасту
    let nh3Cal: Bool?   // Откалиброван ли NH3
    let r: [Bool]?      // Состояния 5 реле [L1..L4, Light]
    let events: [String]? // Тексты экстренных событий
    
    enum CodingKeys: String, CodingKey {
        case t, tt, h, th, l, w, lid, door, p, fan, a, mode
        case age, ageOffset, breed, co2, nh3, iaq, fanLimit, nh3Cal
        case r, events
    }
}