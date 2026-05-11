//
//  AlarmRepository.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import SwiftData
import Foundation

@MainActor
public final class AlarmRepository {
    private let context: ModelContext
    public init(context: ModelContext) { self.context = context }
    
    public func save(_ event: AlarmEvent) {
        context.insert(event)
        try? context.save()
    }
    
    public func fetchActive() -> [AlarmEvent] {
        let descriptor = FetchDescriptor<AlarmEvent>(
            predicate: #Predicate { $0.isActive == true },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }
    
    public func fetchRecent(limit: Int = 50) -> [AlarmEvent] {
        let descriptor = FetchDescriptor<AlarmEvent>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)],
            limit: limit
        )
        return (try? context.fetch(descriptor)) ?? []
    }
    
    public func deactivate(for deviceId: UUID, condition: AlarmCondition) {
        let descriptor = FetchDescriptor<AlarmEvent>(
            predicate: #Predicate { 
                $0.deviceId == deviceId && 
                $0.condition == condition && 
                $0.isActive == true 
            }
        )
        let events = (try? context.fetch(descriptor)) ?? []
        events.forEach { 
            $0.isActive = false
            $0.resolvedAt = Date()
        }
        try? context.save()
    }
    
    public func clearResolved(olderThan: Date) {
        let descriptor = FetchDescriptor<AlarmEvent>(
            predicate: #Predicate { $0.isActive == false && $0.timestamp < olderThan }
        )
        let resolved = (try? context.fetch(descriptor)) ?? []
        resolved.forEach { context.delete($0) }
        try? context.save()
    }
}