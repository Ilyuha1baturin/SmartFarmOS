//
//  FarmDevice.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//

import Foundation

/// Базовый контракт для всех устройств — протокольный слой
public protocol FarmDevice: Identifiable, Equatable, Sendable {
    var id: UUID { get }
    var name: String { get set }
    var type: DeviceType { get }
    var ipAddress: String { get set }
    var port: Int { get set }
    var isOnline: Bool { get set }
    var lastSeen: Date { get set }
}

/// Расширение для свойств тревог и состояния сенсоров
public protocol AlarmSensorDevice {
    var waterSensorOk: Bool { get }
    var doorOk: Bool { get }
    var panicAlarm: Bool { get }
    var sensorFault: Bool { get }
    var ageDays: Int { get }
}

/// Реализация по умолчанию для совместимости
public extension AlarmSensorDevice {
    var waterSensorOk: Bool { true }
    var doorOk: Bool { true }
    var panicAlarm: Bool { false }
    var sensorFault: Bool { false }
    var ageDays: Int { 1 }
}
