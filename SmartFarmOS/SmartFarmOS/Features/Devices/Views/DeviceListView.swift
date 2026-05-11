//
//  DeviceListView.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import SwiftUI
import SwiftData

struct DeviceListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FarmDevice.name) var devices: [FarmDevice]
    @State private var editingDevice: FarmDevice?
    @State private var editName = ""
    
    var body: some View {
        List {
            ForEach(devices) { device in
                HStack {
                    Image(systemName: device.type.icon)
                        .foregroundStyle(.secondary)
                    VStack(alignment: .leading) {
                        Text(device.name).font(.headline)
                        Text(device.type.localizedName).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(device.status.rawValue.capitalized)
                        .font(.caption)
                        .foregroundStyle(statusColor(for: device.status))
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) { delete(device) } label: { Label("Удалить", systemImage: "trash") }
                    Button { editingDevice = device; editName = device.name } label: { Label("Изм.", systemImage: "pencil") }
                        .tint(.blue)
                }
            }
        }
        .navigationTitle("Устройства")
        .sheet(isPresented: Binding(get: { editingDevice != nil }, set: { if !$0 { editingDevice = nil } })) {
            NavigationStack {
                Form {
                    TextField("Имя устройства", text: $editName)
                        .textInputAutocapitalization(.words)
                }
                .navigationTitle("Редактировать")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Отмена") { editingDevice = nil } }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Сохранить") {
                            editingDevice?.name = editName
                            try? modelContext.save()
                            editingDevice = nil
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
    
    private func statusColor(for s: DeviceStatus) -> Color {
        switch s { case .online: .green; case .warning: .orange; case .error: .red; case .offline: .gray }
    }
    
    private func delete(_ d: FarmDevice) {
        modelContext.delete(d)
        try? modelContext.save()
    }
}