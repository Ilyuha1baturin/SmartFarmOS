//
//  FarmModels.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//

import Foundation
import SwiftData

// MARK: - Модель устройства
@Model
class FarmDevice: ObservableObject {
    @Attribute(.unique) var id: String
    var name: String
    var type: DeviceType
    var lastTemperature: Double?
    var status: DeviceStatus
    var ipAddress: String?
    var isOnline: Bool
    var addedDate: Date

    init(id: String, name: String, type: DeviceType, lastTemperature: Double? = nil, status: DeviceStatus = .offline, ipAddress: String? = nil, isOnline: Bool = false, addedDate: Date = .now) {
        self.id = id
        self.name = name
        self.type = type
        self.lastTemperature = lastTemperature
        self.status = status
        self.ipAddress = ipAddress
        self.isOnline = isOnline
        self.addedDate = addedDate
    }
}

// MARK: - Перечисления
enum DeviceType: String, Codable, CaseIterable {
    case brooder, beehive, calfHouse, aviary
}

enum DeviceStatus: String, Codable, CaseIterable {
    case online, warning, error, offline
}

// MARK: - Расширения для UI
extension DeviceType {
    var icon: String {
        switch self {
        case .brooder: return "house.lamp"
        case .beehive: return "hexagon.3.bottom.lefthalf.filled"
        case .calfHouse: return "house.and.flag"
        case .aviary: return "bird"
        }
    }
    var localizedName: String {
        switch self {
        case .brooder: return "Брудер"
        case .beehive: return "Улей"
        case .calfHouse: return "Домик телят"
        case .aviary: return "Вольер"
        }
    }
}
