//
//  Breed.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import Foundation

/// Породы птиц — соответствует `BreedProfile` из main.cpp
public enum Breed: String, CaseIterable, Identifiable, Codable {
    case broiler = "broiler"          // Бройлер
    case layer = "layer"              // Несушка
    case dualPurpose = "dual"         // Мясо-яичная
    case quail = "quail"              // Перепел
    case turkey = "turkey"            // Индюк
    case duck = "duck"                // Утка
    case goose = "goose"              // Гусь
    case guineaFowl = "guinea"        // Цесарка
    
    public var id: String { rawValue }
    
    public var localizedName: String {
        switch self {
        case .broiler: return "Бройлер"
        case .layer: return "Несушка"
        case .dualPurpose: return "Мясо-яичная"
        case .quail: return "Перепел"
        case .turkey: return "Индюк"
        case .duck: return "Утка"
        case .goose: return "Гусь"
        case .guineaFowl: return "Цесарка"
        }
    }
    
    /// Соответствие индексам из C++ (0–7)
    public var cppIndex: Int {
        switch self {
        case .broiler: return 0; case .layer: return 1; case .dualPurpose: return 2
        case .quail: return 3; case .turkey: return 4; case .duck: return 5
        case .goose: return 6; case .guineaFowl: return 7
        }
    }
    
    public static func fromCppIndex(_ idx: Int) -> Breed {
        Breed.allCases.first { $0.cppIndex == idx } ?? .broiler
    }
}