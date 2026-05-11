//
//  FarmNetworkManager.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import Foundation
import SwiftData
import Combine

@MainActor
public final class FarmNetworkManager: ObservableObject {
    @Published public var discoveredDevices: [BonjourDiscovery.DiscoveredDevice] = []
    
    private let discovery: BonjourDiscovery
    private let modelContext: ModelContext
    private let parserRegistry: (any ParserRegistry)?
    private var activeConnections: [String: DeviceConnection] = [:]
    private var cancellables = Set<AnyCancellable>()
    
    public init(modelContext: ModelContext, parserRegistry: (any ParserRegistry)?) {
        self.modelContext = modelContext
        self.parserRegistry = parserRegistry
        self.discovery = BonjourDiscovery()
        
        discovery.$discoveredDevices
            .assign(to: &$discoveredDevices)
        
        startDiscovery()
    }
    
    public func startDiscovery() {
        discovery.startSearching()
    }
    
    /// Добавляет найденное устройство в SwiftData и начинает подключение
    public func addDevice(_ draft: BonjourDiscovery.DiscoveredDevice) {
        let fetch = FetchDescriptor<DeviceEntity>(
            predicate: #Predicate<DeviceEntity> { $0.ipAddress == draft.ipAddress && $0.port == draft.port }
        )
        let existing = try? modelContext.fetch(fetch).first
        
        guard let entity = existing else {
            let newEntity = DeviceEntity(
                id: UUID(),
                name: draft.name,
                type: draft.deviceType,
                ipAddress: draft.ipAddress,
                port: draft.port,
                isConnected: false,
                lastUpdated: Date()
            )
            modelContext.insert(newEntity)
            try? modelContext.save()
            connect(to: newEntity)
            return
        }
        
        connect(to: existing!)
    }
    
    private func connect(to entity: DeviceEntity) {
        let key = entity.ipAddress
        if activeConnections[key] != nil { return }
        
        let conn = DeviceConnection(ip: entity.ipAddress, port: entity.port, parser: parserRegistry)
        activeConnections[key] = conn
        
        // Подписка на состояние соединения
        conn.$state
            .sink { [weak self] state in
                Task { @MainActor [weak self] in
                    entity.isConnected = (state == .ready)
                    entity.lastUpdated = Date()
                    try? self?.modelContext.save()
                }
            }
            .store(in: &cancellables)
        
        // Подписка на распарсенное состояние
        conn.$parsedState
            .compactMap { $0 }
            .sink { [weak self] device in
                Task { @MainActor [weak self] in
                    entity.name = device.name
                    entity.lastUpdated = device.lastUpdated
                    // Здесь можно мапить специфичные поля (temp, humidity и т.д.)
                    try? self?.modelContext.save()
                }
            }
            .store(in: &cancellables)
            
        conn.start()
    }
    
    public func disconnect(from entity: DeviceEntity) {
        let key = entity.ipAddress
        activeConnections[key]?.stop()
        activeConnections.removeValue(forKey: key)
    }
}