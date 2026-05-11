//
//  BrooderParserError.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import Foundation

enum BrooderParserError: Error {
    case invalidData
    case decodingFailed(Error)
}

struct BrooderParser {
    static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .useDefaultKeys
        return d
    }()
    
    static func parseState(from  Data) throws -> BrooderStateDTO {
        do {
            return try decoder.decode(BrooderStateDTO.self, from: data)
        } catch {
            throw BrooderParserError.decodingFailed(error)
        }
    }
    
    /// Вспомогательный метод для парсинга советов (отдельный WS-пакет)
    struct TipsPayload: Codable {
        let type: String
        let tips: TipsContent
    }
    struct TipsContent: Codable {
        let current: [TipItem]?
        let past: [TipItem]?
        let future: [TipItem]?
        let rotating: [String]?
    }
    struct TipItem: Codable {
        let day: Int
        let text: String
        let type: String?
    }
    
    static func parseTips(from  Data) -> TipsContent? {
        guard let payload = try? decoder.decode(TipsPayload.self, from: data),
              payload.type == "tips" else { return nil }
        return payload.tips
    }
}