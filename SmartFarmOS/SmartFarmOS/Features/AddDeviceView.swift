//
//  AddDeviceView.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import SwiftUI
import SwiftData

struct AddDeviceView: View {
    @StateObject private var networkManager: FarmNetworkManager
    @Environment(\.modelContext) private var modelContext
    @State private var showSuccessToast = false
    
    init(networkManager: FarmNetworkManager) {
        _networkManager = StateObject(wrappedValue: networkManager)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Тёмный фон с градиентом
                LinearGradient(
                    colors: [Color(red: 0.08, green: 0.09, blue: 0.12), Color.black],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if networkManager.discoveredDevices.isEmpty {
                    emptyStateView
                } else {
                    devicesListView
                }
            }
            .navigationTitle("Добавить устройство")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        networkManager.startDiscovery()
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .rotationEffect(.degrees(showSuccessToast ? 360 : 0))
                            .animation(.linear(duration: 0.5), value: showSuccessToast)
                    }
                    .tint(.mint)
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.4)
                .tint(.green)
            Text("Сканирование локальной сети...")
                .foregroundStyle(.secondary)
            Text("Убедитесь, что ESP32 подключён к Wi-Fi и публикует сервис\n`_smartfarm._tcp` с TXT-записью `type=brooder` (или другим)")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.tertiary)
                .padding(.horizontal, 32)
        }
    }
    
    private var devicesListView: some View {
        List(networkManager.discoveredDevices, id: \.id) { device in
            DeviceDiscoveryRow(device: device) {
                networkManager.addDevice(device)
                withAnimation { showSuccessToast = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    showSuccessToast = false
                }
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button {
                    networkManager.addDevice(device)
                } label: {
                    Label("Добавить", systemImage: "plus.app")
                }
                .tint(.green)
            }
        }
        .scrollContentBackground(.hidden)
        .listStyle(.insetGrouped)
    }
}

// MARK: - Row Component (Glassmorphism)
struct DeviceDiscoveryRow: View {
    let device: BonjourDiscovery.DiscoveredDevice
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(.green.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: iconForType(device.deviceType))
                    .font(.title2)
                    .foregroundStyle(.green)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(device.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                HStack(spacing: 8) {
                    Label(device.ipAddress, systemImage: "network")
                    Label("\(device.port)", systemImage: "door.right.hand.open")
                    Text(device.deviceType.rawValue.capitalized)
                        .foregroundStyle(.secondary)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button(action: action) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
        )
        .contentShape(Rectangle())
        .onTapGesture { action() }
    }
    
    private func iconForType(_ type: DeviceType) -> String {
        switch type {
        case .brooder: return "flame"
        case .beehive: return "beehive"
        case .calfHouse: return "house"
        case .enclosure: return "camera.viewfinder"
        default: return "cpu"
        }
    }
}