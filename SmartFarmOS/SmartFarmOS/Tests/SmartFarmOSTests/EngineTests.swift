//
//  EngineTests.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import XCTest
@testable import SmartFarmOS

final class EngineTests: XCTestCase {
    func testAlarmEngine_TemperatureHigh() {
        let engine = AlarmEngine()
        let dev = DemoDeviceFactory.makeBrooder()
        dev.climate?.temperature = 39.5
        
        let alarms = engine.evaluate(device: dev)
        XCTAssertTrue(alarms.contains(.tempHigh), "Должен сработать алерт tempHigh")
    }
    
    func testAlarmEngine_CleanState() {
        let engine = AlarmEngine()
        let dev = DemoDeviceFactory.makeBrooder()
        dev.climate = ClimateData(temp: 32.0, hum: 65, co2: 420, nh3: 12)
        
        let alarms = engine.evaluate(device: dev)
        XCTAssertTrue(alarms.isEmpty, "Нормальные параметры не должны вызывать алертов")
    }
    
    func testTipsEngine_DailyRotation() {
        let engine = TipsEngine()
        let tip1 = engine.getNextDaily()
        let tip2 = engine.getNextDaily()
        XCTAssertNotEqual(tip1, tip2, "Советы не должны повторяться подряд")
        XCTAssertTrue(tip1.count > 10)
    }
    
    func testTipsEngine_CalendarBased() {
        let engine = TipsEngine()
        XCTAssertEqual(engine.getTipForDay(2, type: .brooder), "Контролируйте влажность >60%")
        XCTAssertEqual(engine.getTipForDay(22, type: .brooder), "Переведите на естественный свет")
    }
}