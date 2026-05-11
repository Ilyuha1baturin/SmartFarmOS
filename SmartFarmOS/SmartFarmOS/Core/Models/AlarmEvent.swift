//
//  AlarmEvent.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import SwiftData
import Foundation

/// Событие тревоги — соответствует логике `checkAlarms()` из main.cpp
@Model
public final class AlarmEvent {
    @Attribute(.unique) public var id: UUID = UUID()
    public var timestamp: Date
    public var deviceId: UUID
    
    // Условие (condition из C++)
    public var condition: AlarmCondition
    public var severity: AlarmSeverity
    public var isActive: Bool
    public var message: String
    public var resolvedAt: Date?
    
    public init(timestamp: Date, deviceId: UUID, condition: AlarmCondition, 
                severity: AlarmSeverity, message: String, isActive: Bool = true) {
        self.timestamp = timestamp; self.deviceId = deviceId
        self.condition = condition; self.severity = severity
        self.message = message; self.isActive = isActive
    }
}

public enum AlarmCondition: String, Codable, CaseIterable {
    case temp_high = "temp_high"          // ≥38°C
    case temp_low = "temp_low"            // <мин. по возрасту
    case no_water = "no_water"            // датчик воды
    case door_open = "door_open"          // крышка/дверь
    case co2_high = "co2_high"            // >1500 ppm
    case nh3_high = "nh3_high"            // >500 ppm
    case panic = "panic"                  // DSP audio alarm
    case sensor_fault = "sensor_fault"    // расхождение датчиков
}

public enum AlarmSeverity: String, Codable {
    case warning = "warning"
    case critical = "critical"
}