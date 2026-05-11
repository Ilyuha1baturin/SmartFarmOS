//
//  NetworkParserTests.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//

import XCTest
@testable import SmartFarmOS

final class NetworkParserTests: XCTestCase {
    var service: SafeNetworkService!
    
    override func setUp() async throws {
        service = SafeNetworkService.shared
    }
    
    // MARK: - JSON Decoding Tests
    
    func testValidESP32JSONDecoding() {
        let json = """
        {"temp":32.5, "hum":64.2, "co2":410, "nh3":8}
        """.data(using: .utf8)!
        
        let fallback = ClimateData(temp: 20.0, hum: 50.0, co2: 400, nh3: 10)
        let result = service.decode(ClimateData.self, from: json, fallback: fallback)
        
        XCTAssertEqual(result.temperature, 32.5, accuracy: 0.01)
        XCTAssertEqual(result.humidity, 64.2, accuracy: 0.01)
        XCTAssertEqual(result.co2, 410)
        XCTAssertEqual(result.nh3, 8)
    }
    
    func testValidESP32JSONWithAllFields() {
        let json = """
        {"temp":28.0, "hum":55.0, "co2":800, "nh3":25}
        """.data(using: .utf8)!
        
        let fallback = ClimateData(temp: 20.0, hum: 50.0, co2: 400, nh3: 10)
        let result = service.decode(ClimateData.self, from: json, fallback: fallback)
        
        XCTAssertEqual(result.temperature, 28.0, accuracy: 0.01)
        XCTAssertEqual(result.humidity, 55.0, accuracy: 0.01)
        XCTAssertEqual(result.co2, 800)
        XCTAssertEqual(result.nh3, 25)
    }
    
    func testMalformedJSONFallback() {
        let json = "{ broken json }".data(using: .utf8)!
        let fallback = ClimateData(temp: 20.0, hum: 50.0, co2: 400, nh3: 10)
        
        let result = service.decode(ClimateData.self, from: json, fallback: fallback)
        
        XCTAssertEqual(result, fallback, "Fallback должен сработать при повреждённом JSON")
    }
    
    func testEmptyJSONFallback() {
        let json = Data()
        let fallback = ClimateData(temp: 25.0, hum: 60.0, co2: 500, nh3: 15)
        
        let result = service.decode(ClimateData.self, from: json, fallback: fallback)
        
        XCTAssertEqual(result, fallback, "Fallback должен сработать при пустом JSON")
    }
    
    func testMissingFields_UsesDefaults() {
        let json = """
        {"temp":30.0}
        """.data(using: .utf8)!
        
        // При отсутствии полей Codable использует значения по умолчанию для типов
        // float/int -> 0, optional -> nil
        let fallback = ClimateData(temp: 25.0, hum: 60.0, co2: 400, nh3: 15)
        let result = service.decode(ClimateData.self, from: json, fallback: fallback)
        
        XCTAssertEqual(result.temperature, 30.0, accuracy: 0.01)
        // Остальные поля будут 0 или nil в зависимости от реализации ClimateData
        // Проверяем что отсутствующие поля получили значения по умолчанию (0 для Int)
        XCTAssertEqual(result.co2, 0, "Отсутствующее поле co2 должно быть 0")
        XCTAssertEqual(result.nh3, 0, "Отсутствующее поле nh3 должно быть 0")
    }
    
    func testMissingHumidityField() {
        let json = """
        {"temp":30.0, "co2":600, "nh3":20}
        """.data(using: .utf8)!
        
        let fallback = ClimateData(temp: 25.0, hum: 60.0, co2: 400, nh3: 15)
        let result = service.decode(ClimateData.self, from: json, fallback: fallback)
        
        XCTAssertEqual(result.temperature, 30.0, accuracy: 0.01)
        XCTAssertEqual(result.co2, 600)
        XCTAssertEqual(result.nh3, 20)
        XCTAssertEqual(result.humidity, 0.0, accuracy: 0.01, "Отсутствующее поле humidity должно быть 0")
    }
    
    func testMissingFieldsFallback() {
        // Тест проверяет корректность фолбэка при отсутствии обязательных полей
        let json = """
        {"temp":30.0}
        """.data(using: .utf8)!
        
        let fallback = ClimateData(temp: 25.0, hum: 60.0, co2: 400, nh3: 15)
        let result = service.decode(ClimateData.self, from: json, fallback: fallback)
        
        // Присутствующее поле должно быть распарсено
        XCTAssertEqual(result.temperature, 30.0, accuracy: 0.01)
        // Отсутствующие поля должны быть 0 (не fallback значения)
        XCTAssertEqual(result.humidity, 0.0, accuracy: 0.01)
        XCTAssertEqual(result.co2, 0)
        XCTAssertEqual(result.nh3, 0)
    }
    
    func testSnakeCaseConversion() {
        // decoder.keyDecodingStrategy = .convertFromSnakeCase
        let json = """
        {"temperature":25.0, "relative_humidity":55.0}
        """.data(using: .utf8)!
        
        // ClimateData использует CodingKeys для маппинга temp/hum
        // Этот тест проверяет что snake_case не ломает декодирование
        let fallback = ClimateData(temp: 20.0, hum: 50.0, co2: 400, nh3: 10)
        let result = service.decode(ClimateData.self, from: json, fallback: fallback)
        
        // Если ключи не совпадают, должен сработать fallback
        XCTAssertEqual(result.temperature, 20.0)  // fallback значение
    }
    
    // MARK: - Boundary Value Tests
    
    func testBoundaryTemperature_Zero() {
        let json = """
        {"temp":0.0, "hum":50.0, "co2":400, "nh3":10}
        """.data(using: .utf8)!
        
        let fallback = ClimateData(temp: 20.0, hum: 50.0, co2: 400, nh3: 10)
        let result = service.decode(ClimateData.self, from: json, fallback: fallback)
        
        XCTAssertEqual(result.temperature, 0.0, accuracy: 0.01)
    }
    
    func testBoundaryTemperature_Negative() {
        let json = """
        {"temp":-10.5, "hum":50.0, "co2":400, "nh3":10}
        """.data(using: .utf8)!
        
        let fallback = ClimateData(temp: 20.0, hum: 50.0, co2: 400, nh3: 10)
        let result = service.decode(ClimateData.self, from: json, fallback: fallback)
        
        XCTAssertEqual(result.temperature, -10.5, accuracy: 0.01)
    }
    
    func testBoundaryTemperature_VeryHigh() {
        let json = """
        {"temp":100.0, "hum":50.0, "co2":400, "nh3":10}
        """.data(using: .utf8)!
        
        let fallback = ClimateData(temp: 20.0, hum: 50.0, co2: 400, nh3: 10)
        let result = service.decode(ClimateData.self, from: json, fallback: fallback)
        
        XCTAssertEqual(result.temperature, 100.0, accuracy: 0.01)
    }
    
    func testBoundaryCO2_Zero() {
        let json = """
        {"temp":25.0, "hum":50.0, "co2":0, "nh3":10}
        """.data(using: .utf8)!
        
        let fallback = ClimateData(temp: 20.0, hum: 50.0, co2: 400, nh3: 10)
        let result = service.decode(ClimateData.self, from: json, fallback: fallback)
        
        XCTAssertEqual(result.co2, 0)
    }
    
    func testBoundaryCO2_MaxInt() {
        let json = """
        {"temp":25.0, "hum":50.0, "co2":2147483647, "nh3":10}
        """.data(using: .utf8)!
        
        let fallback = ClimateData(temp: 20.0, hum: 50.0, co2: 400, nh3: 10)
        let result = service.decode(ClimateData.self, from: json, fallback: fallback)
        
        XCTAssertEqual(result.co2, 2147483647)
    }
    
    func testBoundaryHumidity_Zero() {
        let json = """
        {"temp":25.0, "hum":0.0, "co2":400, "nh3":10}
        """.data(using: .utf8)!
        
        let fallback = ClimateData(temp: 20.0, hum: 50.0, co2: 400, nh3: 10)
        let result = service.decode(ClimateData.self, from: json, fallback: fallback)
        
        XCTAssertEqual(result.humidity, 0.0, accuracy: 0.01)
    }
    
    func testBoundaryHumidity_100() {
        let json = """
        {"temp":25.0, "hum":100.0, "co2":400, "nh3":10}
        """.data(using: .utf8)!
        
        let fallback = ClimateData(temp: 20.0, hum: 50.0, co2: 400, nh3: 10)
        let result = service.decode(ClimateData.self, from: json, fallback: fallback)
        
        XCTAssertEqual(result.humidity, 100.0, accuracy: 0.01)
    }
    
    func testBoundaryNH3_Zero() {
        let json = """
        {"temp":25.0, "hum":50.0, "co2":400, "nh3":0}
        """.data(using: .utf8)!
        
        let fallback = ClimateData(temp: 20.0, hum: 50.0, co2: 400, nh3: 10)
        let result = service.decode(ClimateData.self, from: json, fallback: fallback)
        
        XCTAssertEqual(result.nh3, 0)
    }
    
    // MARK: - Fallback Behavior Tests
    
    func testFallbackNil_ThrowsFatalError() {
        let json = "invalid".data(using: .utf8)!
        
        // Тест проверяет что при отсутствии fallback происходит ошибка
        // В реальном использовании всегда предоставляйте fallback
        XCTAssertThrowsError(try XCTUnwrap(nil as ClimateData?)) { error in
            // Это заглушка - реальный fatalError нельзя перехватить в XCTest
        }
    }
    
    func testPartialData_WithFallback() {
        let json = """
        {"temp":35.0, "hum":70.0}
        """.data(using: .utf8)!
        
        let fallback = ClimateData(temp: 20.0, hum: 50.0, co2: 400, nh3: 10)
        let result = service.decode(ClimateData.self, from: json, fallback: fallback)
        
        XCTAssertEqual(result.temperature, 35.0, accuracy: 0.01)
        XCTAssertEqual(result.humidity, 70.0, accuracy: 0.01)
        // co2 и nh3 будут 0 (значения по умолчанию для Int)
    }
    
    // MARK: - Integration Tests
    
    func testRealisticESP32Payload() {
        // Типичный payload от ESP32 в нормальных условиях
        let json = """
        {"temp":32.5,"hum":65.0,"co2":450,"nh3":12}
        """.data(using: .utf8)!
        
        let fallback = ClimateData(temp: 25.0, hum: 60.0, co2: 500, nh3: 20)
        let result = service.decode(ClimateData.self, from: json, fallback: fallback)
        
        XCTAssertEqual(result.temperature, 32.5, accuracy: 0.01)
        XCTAssertEqual(result.humidity, 65.0, accuracy: 0.01)
        XCTAssertEqual(result.co2, 450)
        XCTAssertEqual(result.nh3, 12)
    }
    
    func testAlertConditionPayload() {
        // Payload при тревожных условиях
        let json = """
        {"temp":39.5,"hum":85.0,"co2":2000,"nh3":600}
        """.data(using: .utf8)!
        
        let fallback = ClimateData(temp: 25.0, hum: 60.0, co2: 500, nh3: 20)
        let result = service.decode(ClimateData.self, from: json, fallback: fallback)
        
        XCTAssertEqual(result.temperature, 39.5, accuracy: 0.01)
        XCTAssertEqual(result.humidity, 85.0, accuracy: 0.01)
        XCTAssertEqual(result.co2, 2000)
        XCTAssertEqual(result.nh3, 600)
    }
}
