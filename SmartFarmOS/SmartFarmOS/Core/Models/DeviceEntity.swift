//
//  DeviceEntity.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import SwiftData
import Foundation

/// SwiftData-модель, объединяющая все протоколы в единую сущность
@Model
public final class DeviceEntity: FarmDevice, ClimateControllable, RelayControllable, Feedable, Weighable {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var type: DeviceType
    public var isOnline: Bool
    public var lastSeen: Date
    
    public var targetTemperature: Double
    public var currentTemperature: Double
    public var targetHumidity: Double
    public var currentHumidity: Double
    public var fanSpeed: Double
    
    public var relayStates: [Bool]
    public var feedLevel: Double
    public var feedSchedule: [DateComponents]
    public var currentWeight: Double
    
    // Связь one-to-many: устройство -> история телеметрии
    @Relationship(deleteRule: .cascade, inverse: \TelemetryReading.device)
    public var telemetryReadings: [TelemetryReading]
    
    public init(id: UUID = UUID(), name: String, type: DeviceType, isOnline: Bool = false, lastSeen: Date = Date(),
                targetTemperature: Double = 33.0, currentTemperature: Double = 25.0,
                targetHumidity: Double = 65.0, currentHumidity: Double = 50.0, fanSpeed: Double = 0.0,
                relayStates: [Bool] = Array(repeating: false, count: 5),
                feedLevel: Double = 1.0, feedSchedule: [DateComponents] = [],
                currentWeight: Double = 0.0) {
        self.id = id
        self.name = name
        self.type = type
        self.isOnline = isOnline
        self.lastSeen = lastSeen
        self.targetTemperature = targetTemperature
        self.currentTemperature = currentTemperature
        self.targetHumidity = targetHumidity
        self.currentHumidity = currentHumidity
        self.fanSpeed = fanSpeed
        self.relayStates = relayStates
        self.feedLevel = feedLevel
        self.feedSchedule = feedSchedule
        self.currentWeight = currentWeight
        self.telemetryReadings = []
    }
}