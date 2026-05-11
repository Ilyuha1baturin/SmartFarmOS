//
//  MainAppView.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import SwiftUI
import SwiftData

struct MainAppView: View {
    @State private var coordinator = NavigationCoordinator()
    
    var body: some View {
        #if os(macOS)
        NavigationSplitView {
            List {
                Label("Ферма", systemImage: "house.fill").tag(nil as FarmDevice?)
                Label("Устройства", systemImage: "network")
                Label("ИИ-чат", systemImage: "bubble.left.and.bubble.right")
                Label("Настройки", systemImage: "gearshape")
            }
            .listStyle(.sidebar)
        } detail: {
            if let device = coordinator.selectedDevice {
                DeviceDashboardRouter(device: device)
            } else {
                FarmMapView()
            }
        }
        #else
        TabView(selection: $coordinator.activeTab) {
            NavigationStack { FarmMapView() }
                .tabItem { Label("Ферма", systemImage: "house.fill") }
                .tag(NavigationCoordinator.AppTab.farm)
            
            NavigationStack { DeviceListView() }
                .tabItem { Label("Устройства", systemImage: "network") }
                .tag(NavigationCoordinator.AppTab.devices)
            
            NavigationStack { AIChatView() }
                .tabItem { Label("ИИ-чат", systemImage: "bubble.left.and.bubble.right") }
                .tag(NavigationCoordinator.AppTab.ai)
            
            NavigationStack { SettingsView() }
                .tabItem { Label("Настройки", systemImage: "gearshape") }
                .tag(NavigationCoordinator.AppTab.settings)
        }
        #endif
        .environment(coordinator)
        .preferredColorScheme(.dark)
    }
}