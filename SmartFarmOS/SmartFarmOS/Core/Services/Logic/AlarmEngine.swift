//
//  AlarmEngine.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import SwiftData
import Observation

/// Движок генерации тревог — воспроизводит `checkAlarms()` из main.cpp
@MainActor
@Observable
public final class AlarmEngine {
    public var activeAlarms: [AlarmEvent] = []
    
    private let alarmRepo: AlarmRepository
    private let telemetryRepo: TelemetryRepository
    
    public init(alarmRepo: AlarmRepository, telemetryRepo: TelemetryRepository) {
        self.alarmRepo = alarmRepo
        self.telemetryRepo = telemetryRepo
        Task { await refresh() }
    }
    
    /// Проверка всех устройств в контексте
    public func checkAllDevices(in context: ModelContext) {
        let descriptor = FetchDescriptor<DeviceEntity>()
        guard let devices = try? context.fetch(descriptor) else { return }
        
        var newAlarms: [AlarmEvent] = []
        
        for device in devices {
            let latest = device.telemetry.sorted { $0.timestamp > $1.timestamp }.first
            let deviceAlarms = evaluate(device: device, telemetry: latest)
            newAlarms.append(contentsOf: deviceAlarms)
        }
        
        // Сохранение и обновление состояния
        for alarm in newAlarms { alarmRepo.save(alarm) }
        activeAlarms = alarmRepo.fetchActive()
    }
    
    /// Оценка одного устройства
    private func evaluate(device: DeviceEntity, telemetry: TelemetryReading?) -> [AlarmEvent] {
        var alarms: [AlarmEvent] = []
        let now = Date()
        
        let temp = telemetry?.temperature ?? Double.nan
        let co2 = telemetry?.co2 ?? 0
        let nh3 = telemetry?.nh3 ?? 0
        let age = max(1, device.ageDays)
        
        // Формула мин. температуры из main.cpp: max(15.0, 20.0 - max(0, age-21)*0.3)
        let minTempAlarm = max(15.0, 20.0 - max(0, Double(age - 21)) * 0.3)
        
        // Температурные пороги
        if !temp.isNaN && temp >= 38.0 {
            alarms.append(AlarmEvent(timestamp: now, deviceId: device.id, 
                                   condition: .temp_high, severity: .critical,
                                   message: "Критическая температура ≥38°C"))
        } else if !temp.isNaN && temp <= minTempAlarm {
            alarms.append(AlarmEvent(timestamp: now, deviceId: device.id,
                                   condition: .temp_low, severity: .warning,
                                   message: "Температура ниже возрастной нормы"))
        }
        
        // Аппаратные датчики
        if !device.waterSensorOk {
            alarms.append(AlarmEvent(timestamp: now, deviceId: device.id,
                                   condition: .no_water, severity: .critical,
                                   message: "Отсутствует вода"))
        }
        if !device.doorOk {
            alarms.append(AlarmEvent(timestamp: now, deviceId: device.id,
                                   condition: .door_open, severity: .warning,
                                   message: "Крышка/дверь открыта"))
        }
        
        // Газы
        if co2 > 1500 {
            alarms.append(AlarmEvent(timestamp: now, deviceId: device.id,
                                   condition: .co2_high, severity: .warning,
                                   message: "CO₂ > 1500 ppm"))
        }
        if nh3 > 500 {
            alarms.append(AlarmEvent(timestamp: now, deviceId: device.id,
                                   condition: .nh3_high, severity: .critical,
                                   message: "Аммиак > 500 ppm"))
        }
        
        // DSP-паника и неисправности
        if device.panicAlarm {
            alarms.append(AlarmEvent(timestamp: now, deviceId: device.id,
                                   condition: .panic, severity: .critical,
                                   message: "Паника птиц (DSP-анализ)"))
        }
        if device.sensorFault {
            alarms.append(AlarmEvent(timestamp: now, deviceId: device.id,
                                   condition: .sensor_fault, severity: .critical,
                                   message: "Неисправность датчиков"))
        }
        
        return alarms
    }
    
    /// Снятие тревоги
    public func resolveAlarm(for deviceId: UUID, condition: AlarmCondition) {
        alarmRepo.deactivate(for: deviceId, condition: condition)
        activeAlarms = alarmRepo.fetchActive()
    }
    
    /// Обновление списка активных тревог
    public func refresh() {
        activeAlarms = alarmRepo.fetchActive()
    }
}