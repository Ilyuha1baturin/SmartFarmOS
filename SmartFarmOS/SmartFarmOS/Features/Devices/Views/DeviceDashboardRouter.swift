//
//  DeviceDashboardRouter.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import SwiftUI

struct DeviceDashboardRouter: View {
    let device: FarmDevice
    
    var body: some View {
        Group {
            switch device.type {
            case .brooder: BrooderDashboard(device: device)
            case .beehive: BeeHiveDashboard(device: device)
            case .calfHouse: CalfHouseDashboard(device: device)
            case .aviary: AviaryDashboard(device: device)
            }
        }
        .navigationTitle(device.name)
    }
}

// MARK: - Заглушки дашбордов (для компиляции)
struct BrooderDashboard: View { let device: FarmDevice; var body: some View { Text("Брудер: \(device.name)") } }
struct BeeHiveDashboard: View { let device: FarmDevice; var body: some View { Text("Улей: \(device.name)") } }
struct CalfHouseDashboard: View { let device: FarmDevice; var body: some View { Text("Домик телят: \(device.name)") } }
struct AviaryDashboard: View { let device: FarmDevice; var body: some View { Text("Вольер: \(device.name)") } }