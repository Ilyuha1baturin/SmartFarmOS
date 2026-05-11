//
//  TipsEngine.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import Foundation

/// Научные профили выращивания — точные данные из main.cpp
public final class TipsEngine {
    public static let shared = TipsEngine()
    
    /// Профиль дня — соответствует `DayProfile` из C++
    public struct DayProfile: Equatable {
        public let day: Int
        public let targetTemp: Double    // °C
        public let targetHum: Int        // %
        public let lightHours: Int       // ч
        public let luxMin: Int           // lx
        public let maxFanPercent: Int    // 0–100
        
        public init(day: Int, targetTemp: Double, targetHum: Int, lightHours: Int, luxMin: Int, maxFanPercent: Int) {
            self.day = day; self.targetTemp = targetTemp; self.targetHum = targetHum
            self.lightHours = lightHours; self.luxMin = luxMin; self.maxFanPercent = maxFanPercent
        }
    }
    
    // MARK: - Профили (8 пород, как в main.cpp)
    private let profiles: [Breed: [DayProfile]] = [
        .broiler: [
            .init(day:1, targetTemp:33.0, targetHum:65, lightHours:24, luxMin:40, maxFanPercent:50),
            .init(day:2, targetTemp:32.5, targetHum:65, lightHours:24, luxMin:40, maxFanPercent:50),
            .init(day:3, targetTemp:32.0, targetHum:63, lightHours:24, luxMin:35, maxFanPercent:50),
            .init(day:4, targetTemp:31.0, targetHum:62, lightHours:16, luxMin:20, maxFanPercent:50),
            .init(day:7, targetTemp:30.0, targetHum:60, lightHours:16, luxMin:20, maxFanPercent:60),
            .init(day:10, targetTemp:28.5, targetHum:58, lightHours:12, luxMin:10, maxFanPercent:70),
            .init(day:14, targetTemp:27.0, targetHum:55, lightHours:12, luxMin:10, maxFanPercent:80),
            .init(day:21, targetTemp:24.0, targetHum:55, lightHours:10, luxMin:5, maxFanPercent:100),
            .init(day:28, targetTemp:21.0, targetHum:50, lightHours:8, luxMin:5, maxFanPercent:100),
            .init(day:35, targetTemp:20.0, targetHum:50, lightHours:8, luxMin:5, maxFanPercent:100)
        ],
        .layer: [
            .init(day:1, targetTemp:35.0, targetHum:70, lightHours:24, luxMin:50, maxFanPercent:40),
            .init(day:3, targetTemp:33.5, targetHum:68, lightHours:22, luxMin:40, maxFanPercent:40),
            .init(day:7, targetTemp:31.0, targetHum:65, lightHours:18, luxMin:20, maxFanPercent:50),
            .init(day:14, targetTemp:28.0, targetHum:60, lightHours:16, luxMin:15, maxFanPercent:60),
            .init(day:21, targetTemp:25.0, targetHum:55, lightHours:14, luxMin:10, maxFanPercent:80),
            .init(day:28, targetTemp:22.0, targetHum:55, lightHours:12, luxMin:5, maxFanPercent:100),
            .init(day:42, targetTemp:20.0, targetHum:50, lightHours:10, luxMin:5, maxFanPercent:100),
            .init(day:56, targetTemp:18.0, targetHum:50, lightHours:8, luxMin:5, maxFanPercent:100)
        ],
        .dualPurpose: [
            .init(day:1, targetTemp:34.0, targetHum:65, lightHours:24, luxMin:40, maxFanPercent:45),
            .init(day:4, targetTemp:32.0, targetHum:63, lightHours:18, luxMin:20, maxFanPercent:50),
            .init(day:7, targetTemp:30.0, targetHum:60, lightHours:16, luxMin:15, maxFanPercent:60),
            .init(day:14, targetTemp:27.0, targetHum:58, lightHours:12, luxMin:10, maxFanPercent:70),
            .init(day:21, targetTemp:24.0, targetHum:55, lightHours:10, luxMin:5, maxFanPercent:85),
            .init(day:28, targetTemp:21.0, targetHum:50, lightHours:8, luxMin:5, maxFanPercent:100)
        ],
        .quail: [
            .init(day:1, targetTemp:36.5, targetHum:75, lightHours:24, luxMin:50, maxFanPercent:30),
            .init(day:3, targetTemp:35.0, targetHum:72, lightHours:24, luxMin:45, maxFanPercent:30),
            .init(day:7, targetTemp:33.0, targetHum:68, lightHours:22, luxMin:35, maxFanPercent:40),
            .init(day:14, targetTemp:30.0, targetHum:62, lightHours:18, luxMin:20, maxFanPercent:50),
            .init(day:21, targetTemp:27.0, targetHum:58, lightHours:14, luxMin:10, maxFanPercent:70),
            .init(day:28, targetTemp:24.0, targetHum:55, lightHours:10, luxMin:5, maxFanPercent:90),
            .init(day:35, targetTemp:22.0, targetHum:50, lightHours:8, luxMin:5, maxFanPercent:100),
            .init(day:42, targetTemp:20.0, targetHum:50, lightHours:8, luxMin:5, maxFanPercent:100)
        ],
        .turkey: [
            .init(day:1, targetTemp:35.5, targetHum:65, lightHours:24, luxMin:50, maxFanPercent:40),
            .init(day:3, targetTemp:34.0, targetHum:63, lightHours:24, luxMin:45, maxFanPercent:40),
            .init(day:7, targetTemp:32.0, targetHum:62, lightHours:20, luxMin:35, maxFanPercent:50),
            .init(day:14, targetTemp:29.0, targetHum:60, lightHours:17, luxMin:20, maxFanPercent:60),
            .init(day:21, targetTemp:26.0, targetHum:58, lightHours:15, luxMin:10, maxFanPercent:70),
            .init(day:28, targetTemp:23.0, targetHum:55, lightHours:13, luxMin:5, maxFanPercent:80),
            .init(day:35, targetTemp:21.0, targetHum:55, lightHours:11, luxMin:5, maxFanPercent:90),
            .init(day:42, targetTemp:20.0, targetHum:50, lightHours:10, luxMin:5, maxFanPercent:100),
            .init(day:56, targetTemp:18.0, targetHum:50, lightHours:9, luxMin:5, maxFanPercent:100)
        ],
        .duck: [
            .init(day:1, targetTemp:35.0, targetHum:70, lightHours:24, luxMin:40, maxFanPercent:50),
            .init(day:3, targetTemp:34.0, targetHum:68, lightHours:23, luxMin:40, maxFanPercent:50),
            .init(day:7, targetTemp:32.0, targetHum:65, lightHours:20, luxMin:30, maxFanPercent:60),
            .init(day:14, targetTemp:29.0, targetHum:60, lightHours:17, luxMin:15, maxFanPercent:70),
            .init(day:21, targetTemp:26.0, targetHum:58, lightHours:14, luxMin:10, maxFanPercent:85),
            .init(day:28, targetTemp:23.0, targetHum:55, lightHours:12, luxMin:5, maxFanPercent:100),
            .init(day:35, targetTemp:21.0, targetHum:50, lightHours:10, luxMin:5, maxFanPercent:100)
        ],
        .goose: [
            .init(day:1, targetTemp:37.0, targetHum:70, lightHours:24, luxMin:40, maxFanPercent:50),
            .init(day:3, targetTemp:35.0, targetHum:68, lightHours:22, luxMin:40, maxFanPercent:50),
            .init(day:7, targetTemp:32.0, targetHum:65, lightHours:19, luxMin:30, maxFanPercent:60),
            .init(day:10, targetTemp:29.0, targetHum:62, lightHours:17, luxMin:20, maxFanPercent:65),
            .init(day:14, targetTemp:26.0, targetHum:60, lightHours:16, luxMin:15, maxFanPercent:70),
            .init(day:21, targetTemp:23.0, targetHum:58, lightHours:13, luxMin:10, maxFanPercent:85),
            .init(day:28, targetTemp:20.0, targetHum:55, lightHours:11, luxMin:5, maxFanPercent:100)
        ],
        .guineaFowl: [
            .init(day:1, targetTemp:35.0, targetHum:65, lightHours:24, luxMin:45, maxFanPercent:40),
            .init(day:3, targetTemp:34.0, targetHum:63, lightHours:24, luxMin:45, maxFanPercent:40),
            .init(day:7, targetTemp:32.0, targetHum:62, lightHours:21, luxMin:35, maxFanPercent:50),
            .init(day:14, targetTemp:28.0, targetHum:60, lightHours:17, luxMin:15, maxFanPercent:60),
            .init(day:21, targetTemp:25.0, targetHum:58, lightHours:14, luxMin:10, maxFanPercent:70),
            .init(day:28, targetTemp:22.0, targetHum:55, lightHours:11, luxMin:5, maxFanPercent:85),
            .init(day:35, targetTemp:20.0, targetHum:50, lightHours:10, luxMin:5, maxFanPercent:100),
            .init(day:42, targetTemp:18.0, targetHum:50, lightHours:9, luxMin:5, maxFanPercent:100)
        ]
    ]
    
    // MARK: - Публичные API
    
    /// Возвращает профиль для породы
    public func profile(for breed: Breed) -> [DayProfile] {
        profiles[breed] ?? profiles[.broiler]!
    }
    
    /// Ближайший профиль ≤ текущего дня
    public func profileValue(for breed: Breed, ageDays: Int) -> DayProfile? {
        let prof = profile(for: breed)
        let valid = prof.filter { $0.day <= ageDays }
        return valid.max { $0.day < $1.day } ?? prof.first
    }
    
    /// Линейная интерполяция температуры (как в C++)
    public func interpolateTemp(for breed: Breed, ageDays: Int) -> Double {
        let prof = profile(for: breed)
        if ageDays <= prof[0].day { return prof[0].targetTemp }
        if ageDays >= prof.last!.day { return prof.last!.targetTemp }
        for i in 0..<prof.count-1 {
            if ageDays >= prof[i].day && ageDays < prof[i+1].day {
                let d1 = Double(prof[i].day), d2 = Double(prof[i+1].day)
                return prof[i].targetTemp + (prof[i+1].targetTemp - prof[i].targetTemp) * (Double(ageDays) - d1) / (d2 - d1)
            }
        }
        return prof.last!.targetTemp
    }
    
    /// Генерация советов на текущий день
    public func generateTips(ageDays: Int, breed: Breed) -> [Tip] {
        var tips: [Tip] = []
        
        // Календарные советы (упрощённая версия — можно расширить из JSON)
        let calendar: [Int: String] = [
            1: "Подготовьте брудер: проверьте температуру, воду и подстилку.",
            7: "Начало снижения температуры. Проверьте вентиляцию и уровень аммиака.",
            14: "Активное оперение. Контролируйте влажность и чистоту.",
            21: "Переход на взрослый режим. Увеличьте лимит вентилятора.",
            28: "Световой день сокращается. Готовьте помещение к расселению.",
            35: "Финальный этап. Контроль веса и подготовка к реализации."
        ]
        
        // Породные советы
        let species: [Breed: [Int: String]] = [
            .broiler: [21: "Контроль веса: при отставании увеличьте калорийность корма."],
            .layer: [42: "Добавьте кальций в рацион за 2 недели до яйцекладки."],
            .quail: [14: "Сортировка по полу. Плотность посадки — не более 80 шт/м²."]
        ]
        
        if let text = calendar[ageDays] {
            tips.append(Tip(day: ageDays, text: text, type: .calendar))
        }
        if let text = species[breed]?[ageDays] {
            tips.append(Tip(day: ageDays, text: text, type: .species))
        }
        if tips.isEmpty {
            tips.append(Tip(day: ageDays, text: "Продолжайте стандартный уход и наблюдение.", type: .info))
        }
        return tips
    }
}