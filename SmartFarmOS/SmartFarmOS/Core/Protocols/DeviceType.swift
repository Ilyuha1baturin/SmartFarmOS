//
//  DeviceType.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//

import Foundation

/// Типы фермерских устройств — единый источник истины
public enum DeviceType: String, Codable, CaseIterable, Identifiable, Sendable {
    case brooder = "brooder"
    case beehive = "beehive"
    case calfHouse = "calf_house"
    case birdCage = "bird_cage"
    case unknown = "unknown"
    
    public var id: String { rawValue }
    
    public var localizedName: String {
        switch self {
        case .brooder: return "Брудер"
        case .beehive: return "Улей"
        case .calfHouse: return "Домик для телят"
        case .birdCage: return "Вольер (CV)"
        case .unknown: return "Неизвестное устройство"
        }
    }
    
    public var systemImage: String {
        switch self {
        case .brooder: return "thermometer.sun.fill"
        case .beehive: return "hexagon.3.fill"
        case .calfHouse: return "house.lodge.fill"
        case .birdCage: return "eye.fill"
        case .unknown: return "questionmark.circle.fill"
        }
    }
}
