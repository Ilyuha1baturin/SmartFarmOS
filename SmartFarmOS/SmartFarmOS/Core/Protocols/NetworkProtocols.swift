//
//  NetworkProtocols.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//

import Foundation

/// Протокол для парсинга JSON-состояний устройств
public protocol DeviceParser: Sendable {
    associatedtype Output: Decodable
    func parse(data: Data) -> Output?
}

/// Протокол реестра парсеров JSON-состояний
public protocol ParserRegistry: Sendable {
    func canParse(deviceType: DeviceType) -> Bool
    func parse(json: Data, for deviceType: DeviceType) -> (any FarmDevice)?
}

/// Протокол сетевого сервиса с обработкой ошибок
public protocol NetworkServiceProtocol: Sendable {
    func decode<T: Decodable>(_ type: T.Type, from data: Data, fallback: T?) -> T
    func fetchWithRetry<T: Decodable>(url: URL, maxRetries: Int, fallback: T?) async -> T
}
