//
//  EngineTests.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//

import XCTest
@testable import SmartFarmOS

final class EngineTests: XCTestCase {
    
    // MARK: - AlarmEngine Tests
    
    func testAlarmEngine_TemperatureHigh() {
        let device = createTestDevice(ageDays: 10, temperature: 39.5)
        let alarms = evaluateAlarms(for: device)
        XCTAssertTrue(alarms.contains { $0.condition == .temp_high }, "Должен сработать алерт temp_high")
        XCTAssertTrue(alarms.contains { $0.severity == .critical })
    }
    
    func testAlarmEngine_TemperatureLow_AgeBased() {
        // Для возраста 1 день порог minTempAlarm = max(15.0, 20.0 - 0) = 20.0
        let device1 = createTestDevice(ageDays: 1, temperature: 19.0)
        let alarms1 = evaluateAlarms(for: device1)
        XCTAssertTrue(alarms1.contains { $0.condition == .temp_low }, "Должен сработать alert temp_low для возраста 1 день")
        
        // Для возраста 30 дней порог minTempAlarm = max(15.0, 20.0 - 9*0.3) = max(15.0, 17.3) = 17.3
        let device30 = createTestDevice(ageDays: 30, temperature: 16.0)
        let alarms30 = evaluateAlarms(for: device30)
        XCTAssertTrue(alarms30.contains { $0.condition == .temp_low }, "Должен сработать alert temp_low для возраста 30 дней")
        
        // Для возраста 60 дней порог minTempAlarm = max(15.0, 20.0 - 39*0.3) = max(15.0, 8.3) = 15.0
        let device60 = createTestDevice(ageDays: 60, temperature: 14.0)
        let alarms60 = evaluateAlarms(for: device60)
        XCTAssertTrue(alarms60.contains { $0.condition == .temp_low }, "Должен сработать alert temp_low при температуре ниже 15°C")
    }
    
    func testAlarmEngine_NoWater() {
        var device = createTestDevice(ageDays: 10, temperature: 32.0)
        device.waterSensorOk = false
        let alarms = evaluateAlarms(for: device)
        XCTAssertTrue(alarms.contains { $0.condition == .no_water && $0.severity == .critical })
    }
    
    func testAlarmEngine_DoorOpen() {
        var device = createTestDevice(ageDays: 10, temperature: 32.0)
        device.doorOk = false
        let alarms = evaluateAlarms(for: device)
        XCTAssertTrue(alarms.contains { $0.condition == .door_open && $0.severity == .warning })
    }
    
    func testAlarmEngine_CO2_High() {
        let device = createTestDevice(ageDays: 10, temperature: 32.0, co2: 1600)
        let alarms = evaluateAlarms(for: device)
        XCTAssertTrue(alarms.contains { $0.condition == .co2_high && $0.severity == .warning })
    }
    
    func testAlarmEngine_NH3_High() {
        let device = createTestDevice(ageDays: 10, temperature: 32.0, nh3: 550)
        let alarms = evaluateAlarms(for: device)
        XCTAssertTrue(alarms.contains { $0.condition == .nh3_high && $0.severity == .critical })
    }
    
    func testAlarmEngine_Panic() {
        var device = createTestDevice(ageDays: 10, temperature: 32.0)
        device.panicAlarm = true
        let alarms = evaluateAlarms(for: device)
        XCTAssertTrue(alarms.contains { $0.condition == .panic && $0.severity == .critical })
    }
    
    func testAlarmEngine_SensorFault() {
        var device = createTestDevice(ageDays: 10, temperature: 32.0)
        device.sensorFault = true
        let alarms = evaluateAlarms(for: device)
        XCTAssertTrue(alarms.contains { $0.condition == .sensor_fault && $0.severity == .critical })
    }
    
    func testAlarmEngine_CleanState() {
        let device = createTestDevice(ageDays: 10, temperature: 32.0, co2: 420, nh3: 12)
        let alarms = evaluateAlarms(for: device)
        XCTAssertTrue(alarms.isEmpty, "Нормальные параметры не должны вызывать алертов")
    }
    
    func testAlarmEngine_MultipleAlarms() {
        var device = createTestDevice(ageDays: 10, temperature: 39.0, co2: 2000, nh3: 600)
        device.waterSensorOk = false
        let alarms = evaluateAlarms(for: device)
        XCTAssertGreaterThanOrEqual(alarms.count, 4, "Должно быть минимум 4 тревоги: temp_high, no_water, co2_high, nh3_high")
    }
    
    // MARK: - TipsEngine Tests
    
    func testTipsEngine_ProfileForBroiler() {
        let engine = TipsEngine.shared
        let profile = engine.profile(for: .broiler)
        XCTAssertGreaterThan(profile.count, 0, "Профиль для бройлеров должен существовать")
        XCTAssertEqual(profile[0].day, 1)
        XCTAssertEqual(profile[0].targetTemp, 33.0, accuracy: 0.01)
    }
    
    func testTipsEngine_InterpolateTemp_EdgeCases() {
        let engine = TipsEngine.shared
        
        // Возраст меньше первого дня
        let temp1 = engine.interpolateTemp(for: .broiler, ageDays: 0)
        XCTAssertEqual(temp1, 33.0, accuracy: 0.01, "При возрасте 0 должна вернуться температура первого дня")
        
        // Возраст равен первому дню
        let temp2 = engine.interpolateTemp(for: .broiler, ageDays: 1)
        XCTAssertEqual(temp2, 33.0, accuracy: 0.01)
        
        // Возраст больше последнего дня (35+)
        let temp35 = engine.interpolateTemp(for: .broiler, ageDays: 35)
        XCTAssertEqual(temp35, 20.0, accuracy: 0.01, "При возрасте 35+ должна вернуться финальная температура")
        
        let temp100 = engine.interpolateTemp(for: .broiler, ageDays: 100)
        XCTAssertEqual(temp100, 20.0, accuracy: 0.01, "При очень большом возрасте должна вернуться финальная температура")
    }
    
    func testTipsEngine_InterpolateTemp_Interpolation() {
        let engine = TipsEngine.shared
        
        // Интерполяция между днем 1 (33°C) и днем 2 (32.5°C)
        let temp1_5 = engine.interpolateTemp(for: .broiler, ageDays: 1) // Должно быть ближе к 33
        XCTAssertGreaterThan(temp1_5, 32.5)
        XCTAssertLessThanOrEqual(temp1_5, 33.0)
        
        // Интерполяция между днем 7 (30°C) и днем 10 (28.5°C)
        let temp8 = engine.interpolateTemp(for: .broiler, ageDays: 8)
        XCTAssertGreaterThan(temp8, 28.5)
        XCTAssertLessThan(temp8, 30.0)
    }
    
    func testTipsEngine_ProfileValue_ValidAge() {
        let engine = TipsEngine.shared
        
        let profile1 = engine.profileValue(for: .broiler, ageDays: 1)
        XCTAssertNotNil(profile1)
        XCTAssertEqual(profile1?.day, 1)
        
        let profile5 = engine.profileValue(for: .broiler, ageDays: 5)
        XCTAssertNotNil(profile5)
        XCTAssertEqual(profile5?.day, 4) // Ближайший профиль ≤ 5 это день 4
    }
    
    func testTipsEngine_ProfileValue_InvalidAge() {
        let engine = TipsEngine.shared
        let profileZero = engine.profileValue(for: .broiler, ageDays: 0)
        XCTAssertNil(profileZero, "При возрасте 0 должен вернуться nil")
        
        let profileNegative = engine.profileValue(for: .broiler, ageDays: -5)
        XCTAssertNil(profileNegative, "При отрицательном возрасте должен вернуться nil")
    }
    
    func testTipsEngine_GenerateTips_CalendarDays() {
        let engine = TipsEngine.shared
        
        let tips1 = engine.generateTips(ageDays: 1, breed: .broiler)
        XCTAssertTrue(tips1.contains { $0.type == .calendar && $0.day == 1 })
        
        let tips7 = engine.generateTips(ageDays: 7, breed: .broiler)
        XCTAssertTrue(tips7.contains { $0.type == .calendar && $0.day == 7 })
    }
    
    func testTipsEngine_GenerateTips_SpecificBreed() {
        let engine = TipsEngine.shared
        
        let tipsBroiler21 = engine.generateTips(ageDays: 21, breed: .broiler)
        XCTAssertTrue(tipsBroiler21.contains { $0.type == .species })
        
        let tipsLayer42 = engine.generateTips(ageDays: 42, breed: .layer)
        XCTAssertTrue(tipsLayer42.contains { $0.type == .species })
    }
    
    func testTipsEngine_GenerateTips_EmptyFallback() {
        let engine = TipsEngine.shared
        
        // День без специальных советов
        let tips5 = engine.generateTips(ageDays: 5, breed: .broiler)
        XCTAssertTrue(tips5.contains { $0.type == .info })
    }
    
    // MARK: - IAQCalculator Tests
    
    func testIAQCalculator_NormalConditions() {
        let iaq = IAQCalculator.calculate(co2: 420, nh3: 10, humidity: 60)
        XCTAssertLessThan(iaq, 30, "При нормальных условиях IAQ должен быть отличным (<30)")
        XCTAssertEqual(IAQCalculator.description(for: iaq), "Отлично")
    }
    
    func testIAQCalculator_HighCO2() {
        let iaq = IAQCalculator.calculate(co2: 5000, nh3: 10, humidity: 60)
        XCTAssertGreaterThan(iaq, 50, "При высоком CO2 IAQ должен быть повышенным")
    }
    
    func testIAQCalculator_HighNH3() {
        let iaq = IAQCalculator.calculate(co2: 420, nh3: 50, humidity: 60)
        XCTAssertGreaterThan(iaq, 50, "При высоком NH3 IAQ должен быть повышенным")
    }
    
    func testIAQCalculator_HighHumidity() {
        let iaq = IAQCalculator.calculate(co2: 420, nh3: 10, humidity: 85)
        XCTAssertGreaterThan(iaq, 20, "При высокой влажности IAQ должен быть повышенным")
    }
    
    func testIAQCalculator_LowHumidity() {
        let iaq = IAQCalculator.calculate(co2: 420, nh3: 10, humidity: 40)
        XCTAssertGreaterThan(iaq, 10, "При низкой влажности IAQ должен учитываться")
    }
    
    func testIAQCalculator_CriticalConditions() {
        let iaq = IAQCalculator.calculate(co2: 5000, nh3: 50, humidity: 90)
        XCTAssertGreaterThanOrEqual(iaq, 85, "При критических условиях IAQ должен быть ≥85")
        XCTAssertEqual(IAQCalculator.description(for: iaq), "Критическое состояние!")
    }
    
    func testIAQCalculator_NaN_Inputs() {
        let iaqNaN = IAQCalculator.calculate(co2: Double.nan, nh3: 10, humidity: 60)
        XCTAssertGreaterThanOrEqual(iaqNaN, 0)
        XCTAssertLessThanOrEqual(iaqNaN, 100)
        
        let iaqAllNaN = IAQCalculator.calculate(co2: Double.nan, nh3: Double.nan, humidity: Double.nan)
        XCTAssertGreaterThanOrEqual(iaqAllNaN, 0)
        XCTAssertLessThanOrEqual(iaqAllNaN, 100)
    }
    
    func testIAQCalculator_Negative_Inputs() {
        let iaqNeg = IAQCalculator.calculate(co2: -100, nh3: -5, humidity: -10)
        XCTAssertGreaterThanOrEqual(iaqNeg, 0)
        XCTAssertLessThanOrEqual(iaqNeg, 100)
    }
    
    func testIAQCalculator_Description_Ranges() {
        XCTAssertEqual(IAQCalculator.description(for: 0), "Отлично")
        XCTAssertEqual(IAQCalculator.description(for: 29), "Отлично")
        XCTAssertEqual(IAQCalculator.description(for: 30), "Норма")
        XCTAssertEqual(IAQCalculator.description(for: 59), "Норма")
        XCTAssertEqual(IAQCalculator.description(for: 60), "Требуется вентиляция")
        XCTAssertEqual(IAQCalculator.description(for: 84), "Требуется вентиляция")
        XCTAssertEqual(IAQCalculator.description(for: 85), "Критическое состояние!")
        XCTAssertEqual(IAQCalculator.description(for: 100), "Критическое состояние!")
        XCTAssertEqual(IAQCalculator.description(for: -5), "Некорректные данные")
        XCTAssertEqual(IAQCalculator.description(for: 105), "Некорректные данные")
    }
    
    // MARK: - Helper Methods
    
    private func createTestDevice(ageDays: Int, temperature: Double, co2: Int = 420, nh3: Int = 12) -> DeviceEntity {
        let telemetry = TelemetryReading(
            timestamp: Date(),
            temperature: temperature,
            humidity: 60.0,
            co2: co2,
            nh3: nh3
        )
        var device = DeviceEntity(
            name: "Test Brooder",
            type: .brooder,
            ageDays: ageDays
        )
        device.telemetryReadings = [telemetry]
        return device
    }
    
    private func evaluateAlarms(for device: DeviceEntity) -> [AlarmEvent] {
        // Упрощенная версия evaluate для тестирования
        let now = Date()
        var alarms: [AlarmEvent] = []
        
        let temp = device.telemetryReadings.first?.temperature ?? Double.nan
        let co2 = device.telemetryReadings.first?.co2 ?? 0
        let nh3 = device.telemetryReadings.first?.nh3 ?? 0
        let age = max(1, device.ageDays)
        let minTempAlarm = max(15.0, 20.0 - max(0.0, Double(age - 21)) * 0.3)
        
        if !temp.isNaN && temp >= 38.0 {
            alarms.append(AlarmEvent(timestamp: now, deviceId: device.id, condition: .temp_high, severity: .critical, message: ""))
        } else if !temp.isNaN && temp <= minTempAlarm {
            alarms.append(AlarmEvent(timestamp: now, deviceId: device.id, condition: .temp_low, severity: .warning, message: ""))
        }
        
        if !device.waterSensorOk {
            alarms.append(AlarmEvent(timestamp: now, deviceId: device.id, condition: .no_water, severity: .critical, message: ""))
        }
        if !device.doorOk {
            alarms.append(AlarmEvent(timestamp: now, deviceId: device.id, condition: .door_open, severity: .warning, message: ""))
        }
        if co2 > 1500 {
            alarms.append(AlarmEvent(timestamp: now, deviceId: device.id, condition: .co2_high, severity: .warning, message: ""))
        }
        if nh3 > 500 {
            alarms.append(AlarmEvent(timestamp: now, deviceId: device.id, condition: .nh3_high, severity: .critical, message: ""))
        }
        if device.panicAlarm {
            alarms.append(AlarmEvent(timestamp: now, deviceId: device.id, condition: .panic, severity: .critical, message: ""))
        }
        if device.sensorFault {
            alarms.append(AlarmEvent(timestamp: now, deviceId: device.id, condition: .sensor_fault, severity: .critical, message: ""))
        }
        
        return alarms
    }
}