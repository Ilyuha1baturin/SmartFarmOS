//
//  DemoDeviceFactory.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//

import Foundation

/// Фабрика демо-устройств для тестирования и превью
final class DemoDeviceFactory {
    static func makeAll() -> [DemoDevice] {
        return [
            makeBrooder(),
            makeBeeHive(),
            makeCalfHouse(),
            makeBirdCage()
        ]
    }
    
    static func makeBrooder() -> DemoDevice {
        DemoDevice(
            id: UUID(),
            name: "Бройлер-Блок А",
            type: .brooder,
            ipAddress: "192.168.1.100",
            port: 80,
            isOnline: true,
            lastSeen: Date(),
            climate: ClimateData(temp: 33.0, hum: 65, co2: 420, nh3: 12),
            targetTemp: 33.0,
            ageDays: 7,
            breed: .broiler
        )
    }
    
    static func makeBeeHive() -> DemoDevice {
        DemoDevice(
            id: UUID(),
            name: "Улей #7 (Липа)",
            type: .beehive,
            ipAddress: "192.168.1.105",
            port: 80,
            isOnline: true,
            lastSeen: Date(),
            climate: ClimateData(temp: 35.2, hum: 55, co2: 450, nh3: 5),
            targetTemp: 35.0,
            weight: 45.5
        )
    }
    
    static func makeCalfHouse() -> DemoDevice {
        DemoDevice(
            id: UUID(),
            name: "Телятник Север-2",
            type: .calfHouse,
            ipAddress: "192.168.1.112",
            port: 80,
            isOnline: true,
            lastSeen: Date(),
            climate: ClimateData(temp: 14.0, hum: 68, co2: 900, nh3: 45),
            targetTemp: 16.0,
            weight: 85.0
        )
    }
    
    static func makeBirdCage() -> DemoDevice {
        DemoDevice(
            id: UUID(),
            name: "Вольер CV-01",
            type: .birdCage,
            ipAddress: "192.168.1.120",
            port: 80,
            isOnline: true,
            lastSeen: Date(),
            climate: ClimateData(temp: 22.0, hum: 60, co2: 500, nh3: 20),
            targetTemp: 22.0
        )
    }
}

/// Демо-реализация устройства для UI превью
struct DemoDevice: FarmDevice {
    let id: UUID
    var name: String
    let type: DeviceType
    var ipAddress: String
    var port: Int
    var isOnline: Bool
    var lastSeen: Date
    
    var climate: ClimateData?
    var targetTemp: Double?
    var ageDays: Int?
    var breed: Breed?
    var weight: Double?
    
    init(id: UUID = UUID(), name: String, type: DeviceType, ipAddress: String, port: Int = 80,
         isOnline: Bool = true, lastSeen: Date = Date(), climate: ClimateData? = nil,
         targetTemp: Double? = nil, ageDays: Int? = nil, breed: Breed? = nil, weight: Double? = nil) {
        self.id = id; self.name = name; self.type = type
        self.ipAddress = ipAddress; self.port = port
        self.isOnline = isOnline; self.lastSeen = lastSeen
        self.climate = climate; self.targetTemp = targetTemp
        self.ageDays = ageDays; self.breed = breed; self.weight = weight
    }
}
