//
//  DemoDeviceFactory.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import Foundation

final class DemoDeviceFactory {
    static func makeAll() -> [FarmDevice] {
        return [
            makeBrooder(),
            makeBeeHive(),
            makeCalfHouse(),
            makeVisionEnclosure()
        ]
    }
    
    private static func makeBrooder() -> FarmDevice {
        let dev = FarmDevice(name: "Бройлер-Блок А", ipAddress: "192.168.1.100", type: .brooder)
        dev.climate = ClimateData(temp: 33.0, hum: 65, co2: 420, nh3: 12)
        dev.targetTemp = 33.0
        return dev
    }
    
    private static func makeBeeHive() -> FarmDevice {
        let dev = FarmDevice(name: "Улей #7 (Липа)", ipAddress: "192.168.1.105", type: .beehive)
        dev.climate = ClimateData(temp: 35.2, hum: 55, co2: 450, nh3: 5)
        return dev
    }
    
    private static func makeCalfHouse() -> FarmDevice {
        let dev = FarmDevice(name: "Телятник Север-2", ipAddress: "192.168.1.112", type: .calfhouse)
        dev.climate = ClimateData(temp: 14.0, hum: 68, co2: 900, nh3: 45)
        dev.targetTemp = 16.0
        return dev
    }
    
    private static func makeVisionEnclosure() -> FarmDevice {
        let dev = FarmDevice(name: "Вольер CV-01", ipAddress: "192.168.1.120", type: .vision)
        dev.climate = ClimateData(temp: 22.0, hum: 60, co2: 500, nh3: 20)
        return dev
    }
}