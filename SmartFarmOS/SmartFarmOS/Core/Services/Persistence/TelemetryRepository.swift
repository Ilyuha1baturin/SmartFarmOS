//
//  TelemetryRepository.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import SwiftData
import Foundation

@MainActor
public final class TelemetryRepository {
    private let context: ModelContext
    
    public init(context: ModelContext) { self.context = context }
    
    public func save(_ reading: TelemetryReading) {
        context.insert(reading)
        try? context.save()
    }
    
    public func saveBatch(_ readings: [TelemetryReading]) {
        readings.forEach { context.insert($0) }
        try? context.save()
    }
    
    public func fetchLatest(for deviceId: UUID, limit: Int = 720) -> [TelemetryReading] {
        let descriptor = FetchDescriptor<TelemetryReading>(
            predicate: #Predicate { $0.deviceId == deviceId },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)],
            limit: limit
        )
        return (try? context.fetch(descriptor)) ?? []
    }
    
    public func fetchForChart(deviceId: UUID, since: Date) -> [TelemetryReading] {
        let descriptor = FetchDescriptor<TelemetryReading>(
            predicate: #Predicate { $0.deviceId == deviceId && $0.timestamp >= since },
            sortBy: [SortDescriptor(\.timestamp)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }
    
    public func purgeOlderThan(_ cutoff: Date) {
        let descriptor = FetchDescriptor<TelemetryReading>(predicate: #Predicate { $0.timestamp < cutoff })
        let old = (try? context.fetch(descriptor)) ?? []
        old.forEach { context.delete($0) }
        try? context.save()
    }
}