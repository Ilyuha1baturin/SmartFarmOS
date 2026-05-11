//
//  DemoTelemetryService.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import Foundation

@MainActor
final class DemoTelemetryService {
    static let shared = DemoTelemetryService()
    
    func simulateTick(for devices: [FarmDevice]) {
        for device in devices {
            guard var climate = device.climate else { continue }
            
            // Симуляция Random Walk с плавным сглаживанием
            climate.temperature += Float.random(in: -0.4...0.4)
            climate.humidity += Float.random(in: -1.0...1.0)
            climate.co2 += Int.random(in: -15...15)
            climate.nh3 += Int.random(in: -2...2)
            
            // Ограничение физическими пределами
            climate.temperature = climate.temperature.clamped(to: 18.0...42.0)
            climate.humidity = climate.humidity.clamped(to: 40.0...90.0)
            climate.co2 = climate.co2.clamped(to: 350...1200)
            climate.nh3 = climate.nh3.clamped(to: 5...60)
            
            device.climate = climate
            device.lastSeen = Date()
            device.isOnline = true
        }
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}