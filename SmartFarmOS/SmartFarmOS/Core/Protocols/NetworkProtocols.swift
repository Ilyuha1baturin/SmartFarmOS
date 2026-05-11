//
//  NetworkProtocols.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//

import Foundation
import SwiftData

/// Типы поддерживаемых фермерских устройств
public enum DeviceType: String, Codable, CaseIterable, Sendable {
    case brooder = "brooder"
    case beehive = "beehive"
    case calfHouse = "calf_house"
    case enclosure = "enclosure"
    case unknown = "unknown"
}

/// Базовый протокол для любого фермерского устройства
public protocol FarmDevice: Identifiable, Equatable, Sendable {
    var id: UUID { get }
    var name: String { get set }
    var type: DeviceType { get }
    var ipAddress: String { get set }
    var port: Int { get set }
    var isConnected: Bool { get set }
    var lastUpdated: Date { get set }
}

/// Протокол реестра парсеров JSON-состояний
public protocol ParserRegistry {
    func canParse(deviceType: DeviceType) -> Bool
    func parse(json: Data) -> (any FarmDevice)?
}

// ⚠️ Предполагается, что DeviceEntity уже определён в проекте как @Model
// @Model final class DeviceEntity: Identifiable { ... }
