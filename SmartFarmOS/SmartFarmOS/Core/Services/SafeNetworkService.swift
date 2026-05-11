//
//  SafeNetworkService.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import Foundation
import OSLog

final class SafeNetworkService {
    static let shared = SafeNetworkService()
    private let decoder = JSONDecoder()
    private let logger = Logger(subsystem: "com.smartfarm.network", category: "recovery")
    
    init() {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    func decode<T: Decodable>(_ type: T.Type, from data: Data, fallback: T? = nil) -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            logger.error("Decode failed: \(error.localizedDescription). Fallback applied.")
            return fallback ?? (try? decoder.decode(T.self, from: Data()))!
        }
    }
    
    func fetchWithRetry<T: Decodable>(url: URL, maxRetries: Int = 3, fallback: T? = nil) async -> T {
        var delay: Double = 1.0
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
                logger.warning("Attempt \(attempt) failed: \(error.localizedDescription)")
                if attempt < maxRetries {
                    try? await Task.sleep(for: .seconds(delay))
                    delay *= 2.0
                }
            }
        }
        return fallback ?? decode(T.self, from: Data(), fallback: fallback)
    }
}