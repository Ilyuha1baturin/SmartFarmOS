//
//  FarmDevice.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import Foundation
import SwiftData

@Model class FarmDevice: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var ipAddress: String
    var deviceType: DeviceType
    
    var isOnline: Bool = false
    var lastSeen: Date?
    var activeAlarms: [AlarmType] = []
    var lastError: String?
    
    var climate: ClimateData?
    var targetTemp: Float = 25.0
    var targetHum: Float = 60.0
    
    init(name: String, ipAddress: String, type: DeviceType) {
        self.name = name
        self.ipAddress = ipAddress
        self.deviceType = type
    }
}

struct ClimateData: Codable, Equatable {
    var temperature: Float
    var humidity: Float
    var co2: Int
    var nh3: Int
    var timestamp: TimeInterval = Date().timeIntervalSince1970
    
    // Совместимость с JSON от ESP32 (main.cpp)
    enum CodingKeys: String, CodingKey {
        case temperature = "temp"
        case humidity = "hum"
        case co2, nh3
    }
}