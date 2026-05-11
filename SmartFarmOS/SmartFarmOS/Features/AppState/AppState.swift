//
//  AppState.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import Foundation
import SwiftUI
import SwiftData

@Observable @MainActor
final class AppState: ObservableObject {
    var isDemoMode = false
    var devices: [FarmDevice] = []
    var connectionState: ConnectionState = .disconnected
    private(set) var demoTask: Task<Void, Never>?
    
    enum ConnectionState { case disconnected, connecting, connected, reconnecting }
    
    func toggleDemoMode(_ enabled: Bool) {
        isDemoMode = enabled
        if enabled {
            connectionState = .connected
            devices = DemoDeviceFactory.makeAll()
            startDemoTelemetry()
        } else {
            connectionState = .disconnected
            demoTask?.cancel()
            demoTask = nil
            devices.removeAll()
        }
    }
    
    private func startDemoTelemetry() {
        demoTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(2))
                if !Task.isCancelled {
                    DemoTelemetryService.shared.simulateTick(for: devices)
                }
            }
        }
    }
}