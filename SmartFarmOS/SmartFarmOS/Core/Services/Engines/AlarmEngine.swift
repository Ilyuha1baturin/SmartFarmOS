//
//  AlarmEngine.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import Foundation

final class AlarmEngine {
    func evaluate(device: FarmDevice) -> [AlarmType] {
        guard let climate = device.climate else { return device.isOnline ? [] : [.offline] }
        var alarms: [AlarmType] = []
        
        if climate.temperature > 38.0 { alarms.append(.tempHigh) }
        if climate.temperature < 20.0 { alarms.append(.tempLow) }
        if climate.humidity > 85.0 { alarms.append(.humHigh) }
        if climate.nh3 > 50 { alarms.append(.nh3High) }
        if climate.co2 > 1500 { alarms.append(.co2High) }
        
        return alarms
    }
}