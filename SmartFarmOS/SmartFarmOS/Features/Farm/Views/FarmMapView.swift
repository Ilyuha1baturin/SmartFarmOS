//
//  FarmMapView.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import SwiftUI
import SwiftData

struct FarmMapView: View {
    @Environment(NavigationCoordinator.self) private var coordinator
    @Query(sort: \FarmDevice.addedDate, order: .forward) var devices: [FarmDevice]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: adaptiveColumns, spacing: 16) {
                ForEach(devices) { device in
                    DeviceThumbnail(device: device) {
                        coordinator.navigate(to: device)
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .navigationTitle("Ферма")
    }
    
    private var adaptiveColumns: [GridItem] {
        #if os(iOS)
        [GridItem(.adaptive(minimum: 150))]
        #else
        [GridItem(.adaptive(minimum: 180, maximum: 240))]
        #endif
    }
}

// MARK: - Миниатюра устройства (Glass-эффект)
struct DeviceThumbnail: View {
    let device: FarmDevice
    let action: () -> Void
    
    var statusColor: Color {
        switch device.status {
        case .online: .green; case .warning: .orange; case .error: .red; case .offline: .gray
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: device.type.icon)
                    .font(.system(size: 28))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(.ultraThinMaterial, in: Capsule())
                    .overlay(
                        Circle().fill(statusColor)
                            .frame(width: 14, height: 14)
                            .alignmentGuide(.bottomTrailing) { $0[.bottomTrailing].padding(-4) }
                    )
                
                Text(device.name)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                if let temp = device.lastTemperature {
                    Text("\(temp, format: .number.precision(.fractionLength(1)))°C")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("—").font(.caption).foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.15), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}