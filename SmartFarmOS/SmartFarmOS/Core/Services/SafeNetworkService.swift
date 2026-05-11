//
//  SafeNetworkService.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//

import Foundation
import OSLog

/// Сетевой сервис с безопасной обработкой ошибок и fallback-логикой
final class SafeNetworkService: NetworkServiceProtocol {
    static let shared = SafeNetworkService()
    private let decoder = JSONDecoder()
    private let logger = Logger(subsystem: "com.smartfarm.network", category: "recovery")

    init() {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    /// Декодирование с fallback при ошибке
    func decode<T: Decodable>(_ type: T.Type, from data: Data, fallback: T?) -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            logger.error("Decode failed: \(error.localizedDescription). Fallback applied.")
            guard let fallback = fallback else {
                fatalError("No fallback provided for type \(T.self) and no valid data")
            }
            return fallback
        }
    }

    /// Запрос с повторными попытками (exponential backoff)
    func fetchWithRetry<T: Decodable>(url: URL, maxRetries: Int = 3, fallback: T? = nil) async -> T {
        var delay: TimeInterval = 1.0
        var lastError: Error?

        for attempt in 1...maxRetries {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return decode(T.self, from: data, fallback: fallback)
            } catch {
                lastError = error
                logger.warning("Attempt \(attempt)/\(maxRetries) failed: \(error.localizedDescription)")
                if attempt < maxRetries {
                    try? await Task.sleep(for: .seconds(delay))
                    delay *= 2.0  // exponential backoff
                }
            }
        }

        guard let fallback = fallback else {
            fatalError("All network attempts failed and no fallback provided for \(T.self)")
        }
        return fallback
    }
}
