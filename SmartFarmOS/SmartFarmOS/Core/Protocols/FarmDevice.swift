//
//  FarmDevice.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import Foundation

/// Базовый контракт для всех устройств
public protocol FarmDevice: Identifiable {
    var id: UUID { get }
    var name: String { get set }
    var type: DeviceType { get set }
    var isOnline: Bool { get set }
    var lastSeen: Date { get set }
}
