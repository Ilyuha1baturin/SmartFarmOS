//
//  TelemetryReading.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import SwiftData
import Foundation

/// Точка телеметрии — соответствует `DataPoint` из main.cpp
@Model
public final class TelemetryReading {
    @Attribute(.unique) public var id: UUID = UUID()
    public var timestamp: Date
    public var deviceId: UUID
    
    // Сенсоры (значения как в C++: temp*10, hum*10)
    public var temperature: Double?    // °C
    public var humidity: Double?       // %
    public var co2: Int?               // ppm
    public var nh3: Int?               // ppm (delta от baseline)
    public var lux: Int?               // lx
    public var fanSpeed: Int?          // 0–255 PWM
    
    public init(timestamp: Date, deviceId: UUID, temperature: Double? = nil,
                humidity: Double? = nil, co2: Int? = nil, nh3: Int? = nil,
                lux: Int? = nil, fanSpeed: Int? = nil) {
        self.timestamp = timestamp; self.deviceId = deviceId
        self.temperature = temperature; self.humidity = humidity
        self.co2 = co2; self.nh3 = nh3; self.lux = lux; self.fanSpeed = fanSpeed
    }
}
