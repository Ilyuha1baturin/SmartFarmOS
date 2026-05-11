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
        // Защита от отрицательных и NaN значений
        let co2Safe = co2.isNaN || co2 < 0 ? 0 : co2
        let nh3Safe = nh3.isNaN || nh3 < 0 ? 0 : nh3
        let humiditySafe = humidity.isNaN || humidity < 0 ? 50 : humidity
        
        let co2Score = constrain((co2Safe - 1000.0) / 4000.0, 0.0, 1.0)
        let nh3Score = constrain((nh3Safe - 10.0) / 40.0, 0.0, 1.0)
        let rhHigh = constrain((humiditySafe - 70.0) / 15.0, 0.0, 1.0)
        let rhLow = constrain((60.0 - humiditySafe) / 20.0, 0.0, 1.0)
        let rhScore = max(rhHigh, rhLow)
        
        // Веса коэффициентов: 0.3 + 0.5 + 0.2 = 1.0 (корректно)
        return constrain((co2Score * 0.3 + nh3Score * 0.5 + rhScore * 0.2) * 100.0, 0.0, 100.0)
    }
    
    private static func constrain(_ value: Double, _ min: Double, _ max: Double) -> Double {
        Swift.min(Swift.max(value, min), max)
    }
    
    /// Человеческое описание состояния
    public static func description(for iaq: Double) -> String {
        guard iaq >= 0 && iaq <= 100 else { return "Некорректные данные" }
        switch iaq {
        case ..<30: return "Отлично"
        case 30..<60: return "Норма"
        case 60..<85: return "Требуется вентиляция"
        default: return "Критическое состояние!"
        }
    }
}