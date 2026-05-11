//
//  ClimateControllable.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import Foundation

/// Устройства с контролем температуры/влажности/вентиляции
public protocol ClimateControllable {
    var targetTemperature: Double { get set }   // °C
    var currentTemperature: Double { get set }
    var targetHumidity: Double { get set }      // %
    var currentHumidity: Double { get set }
    var fanSpeed: Double { get set }            // 0.0 ... 1.0
}