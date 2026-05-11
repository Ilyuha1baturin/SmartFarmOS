//
//  DashboardPreview.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import SwiftUI

struct DashboardPreview: View {
    @State private var appState = AppState()
    
    var body: some View {
        NavigationStack {
            List(appState.devices, id: \.id) { device in
                HStack {
                    VStack(alignment: .leading) {
                        Text(device.name).font(.headline)
                        Text(device.deviceType.rawValue.capitalized)
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    if let climate = device.climate {
                        VStack(alignment: .trailing) {
                            Text("\(climate.temperature, specifier: "%.1f")°C")
                                .foregroundStyle(climate.temperature > 38 ? .red : .cyan)
                            Text("CO₂: \(climate.co2)")
                        }
                    }
                }
            }
            .navigationTitle("Ферма (Демо)")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Button(appState.isDemoMode ? "🟢 Демо" : "⚫ Оффлайн") {
                        appState.toggleDemoMode(!appState.isDemoMode)
                    }
                }
            }
        }
        .onAppear { appState.toggleDemoMode(true) }
    }
}

#Preview("Dashboard Demo Mode") {
    DashboardPreview()
}

#Preview("Recovery / Offline State") {
    let dev = FarmDevice(name: "Бройлер-Блок А", ipAddress: "192.168.1.100", type: .brooder)
    dev.climate = ClimateData.mock
    dev.isOnline = false
    dev.lastError = "Network unreachable"
    
    return VStack {
        HStack {
            Text(dev.name).font(.headline)
            Spacer()
            Text("⛔ Offline").foregroundStyle(.red)
        }
        .padding()
        .glassBackgroundEffect()
        .frame(width: 320)
        .padding()
    }
}