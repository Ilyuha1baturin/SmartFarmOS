//
//  IAQCalculator.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import Foundation

/// Расчёт индекса качества воздуха — точная копия `calculateIAQ()` из main.cpp
public struct IAQCalculator {
    /// Возвращает 0–100, где 100 = критическое состояние
    public static func calculate(co2: Double, nh3: Double, humidity: Double) -> Double {
        let co2Score = constrain((co2 - 1000.0) / 4000.0, 0.0, 1.0)
        let nh3Score = constrain((nh3 - 10.0) / 40.0, 0.0, 1.0)
        let rhHigh = constrain((humidity - 70.0) / 15.0, 0.0, 1.0)
        let rhLow = constrain((60.0 - humidity) / 20.0, 0.0, 1.0)
        let rhScore = max(rhHigh, rhLow)
        return constrain((co2Score * 0.3 + nh3Score * 0.5 + rhScore * 0.2) * 100.0, 0.0, 100.0)
    }
    
    private static func constrain(_ value: Double, _ min: Double, _ max: Double) -> Double {
        Swift.min(Swift.max(value, min), max)
    }
    
    /// Человеческое описание состояния
    public static func description(for iaq: Double) -> String {
        switch iaq {
        case ..<30: return "Отлично"
        case 30..<60: return "Норма"
        case 60..<85: return "Требуется вентиляция"
        default: return "Критическое состояние!"
        }
    }
}