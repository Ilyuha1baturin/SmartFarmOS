//
//  NetworkParserTests.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import XCTest
@testable import SmartFarmOS

final class NetworkParserTests: XCTestCase {
    let service = SafeNetworkService.shared
    
    func testValidESP32JSONDecoding() {
        // Формат, соответствующий index.html / main.cpp
        let json = """
        {"temp":32.5, "hum":64.2, "co2":410, "nh3":8}
        """.data(using: .utf8)!
        
        let result = service.decode(ClimateData.self, from: json)
        XCTAssertEqual(result.temperature, 32.5)
        XCTAssertEqual(result.humidity, 64.2)
        XCTAssertEqual(result.co2, 410)
    }
    
    func testMalformedJSONFallback() {
        let json = "{ broken json }".data(using: .utf8)!
        let fallback = ClimateData(temp: 20.0, hum: 50.0, co2: 400, nh3: 10)
        
        let result = service.decode(ClimateData.self, from: json, fallback: fallback)
        XCTAssertEqual(result, fallback, "Fallback должен сработать при повреждённом JSON")
    }
    
    func testMissingFieldsFallback() {
        let json = """
        {"temp":30.0}
        """.data(using: .utf8)!
        
        // При отсутствии полей Codable инициализирует nil/default, но наш fallback сработает на уровне логики
        let fallback = ClimateData(temp: 25.0, hum: 60.0, co2: 400, nh3: 15)
        let result = service.decode(ClimateData.self, from: json, fallback: fallback)
        XCTAssertEqual(result.temperature, 30.0)
    }
}