//
//  BrooderDashboard.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import SwiftUI

struct BrooderDashboard: View {
    @ObservedObject var device: BrooderDevice
    @State private var tempSliderVal: Double = 0
    @State private var humSliderVal: Double = 0
    @State private var selectedTipTab: Int = 0
    
    let breedNames = ["Бройлер", "Несушка", "Мясо-яичная", "Перепел", "Индюк", "Утка", "Гусь", "Цесарка"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    if device.alarmActive {
                        AlarmBanner(isPanic: device.isPanic, events: ["Температура", "Газы", "Дверь"])
                    }
                    
                    // 1. Климат
                    ClimateCard(temp: device.currentTemp, targetTemp: $device.targetTemp,
                                hum: device.currentHumidity, targetHum: $device.targetHumidity,
                                iaq: device.iaq, device: device)
                    
                    // 2. Газы
                    GasSection(co2: device.co2, nh3: device.nh3Delta)
                    
                    // 3. Настройки
                    SettingsCard(breedNames: breedNames, device: device)
                    
                    // 4. Вентилятор
                    FanCard(speed: device.fanSpeedPercent, limit: 100)
                    
                    // 5. Безопасность
                    SafetySection(waterOk: device.isWaterOk, lidClosed: device.isLidClosed, doorClosed: device.isDoorClosed)
                    
                    // 6. Советы
                    TipsView(tips: device.tips, selectedTab: $selectedTipTab)
                    
                    // 7. Реле
                    RelayGrid(relayStates: device.relayStates, isAuto: device.isAutoMode, device: device)
                    
                    // 8. Ручное управление (только MAN)
                    if !device.isAutoMode {
                        ManualControlCard(relays: device.relayStates, device: device)
                    }
                    
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal)
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            .navigationTitle("🐣 Брудер")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Circle().fill(device.isConnected ? .green : .red)
                        .frame(width: 10, height: 10)
                }
            }
        }
    }
}

// MARK: - Компоненты панели

private struct ClimateCard: View {
    let temp: Double
    @Binding var targetTemp: Double
    let hum: Double
    @Binding var targetHum: Double
    let iaq: Int
    let device: BrooderDevice
    
    var body: some View {
        GlassCard {
            HStack {
                // Температура
                VStack(alignment: .leading, spacing: 8) {
                    Text("🌡 Температура")
                        .font(.caption).foregroundColor(.secondary)
                    Text(String(format: "%.1f°C", temp))
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                    Slider(value: $targetTemp, in: 15...40, step: 0.5)
                        .onChange(of: targetTemp) { _, newVal in device.setTargetTemp(newVal) }
                }
                
                Divider().background(Color.white.opacity(0.2))
                
                // Влажность
                VStack(alignment: .leading, spacing: 8) {
                    Text("💧 Влажность")
                        .font(.caption).foregroundColor(.secondary)
                    Text(String(format: "%.0f%%", hum))
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                    Slider(value: $targetHum, in: 30...80, step: 1)
                        .onChange(of: targetHum) { _, newVal in device.setTargetHumidity(newVal) }
                }
                
                Spacer()
                
                // IAQ Кольцо
                ZStack {
                    Circle().stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    Circle().trim(from: 0, to: CGFloat(iaq)/100)
                          .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round))
                          .rotationEffect(.degrees(-90))
                          .foregroundColor(iaq > 70 ? .red : iaq > 40 ? .yellow : .green)
                    Text("\(iaq)")
                        .font(.system(size: 14, weight: .bold))
                }
                .frame(width: 50, height: 50)
            }
        }
    }
}

private struct GasSection: View {
    let co2: Int, nh3: Int
    var body: some View {
        GlassCard {
            VStack(spacing: 12) {
                GasBar(label: "🧪 CO₂", value: Double(co2), max: 2000, color: co2 > 1500 ? .red : .blue)
                GasBar(label: "💨 NH₃", value: Double(nh3), max: 500, color: nh3 > 300 ? .red : .orange)
            }
        }
    }
}

private struct GasBar: View {
    let label: String
    let value: Double
    let max: Double
    let color: Color
    
    var body: some View {
        HStack {
            Text(label).frame(width: 80, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color.gray.opacity(0.2)).cornerRadius(4)
                    Rectangle().fill(color).frame(width: geo.size.width * (value/max))
                }
            }
            .frame(height: 8)
            Text(String(format: "%.0f", value)).font(.caption)
        }
    }
}

private struct SettingsCard: View {
    let breedNames: [String]
    @ObservedObject var device: BrooderDevice
    
    var body: some View {
        GlassCard {
            VStack(spacing: 12) {
                HStack {
                    Text("🐓 Порода").frame(width: 60, alignment: .leading)
                    Picker("", selection: $device.breedIndex) {
                        ForEach(breedNames.indices, id: \.self) {
                            Text(breedNames[$0]).tag($0)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: device.breedIndex) { _, v in device.setBreed(v) }
                }
                
                HStack {
                    Text("⚙️ Режим")
                    Toggle("", isOn: $device.isAutoMode)
                        .toggleStyle(.switch)
                        .onChange(of: device.isAutoMode) { _, v in device.setMode(v) }
                    Spacer()
                    Text(device.isAutoMode ? "АВТО" : "РУЧНОЙ")
                        .font(.caption).foregroundColor(.secondary)
                }
                
                HStack {
                    Text("📅 Возраст")
                    Stepper("\(device.ageDays) дн (+\(device.ageOffset))", value: $device.ageOffset, in: -10...30)
                        .onChange(of: device.ageOffset) { _, v in device.setAgeOffset(v) }
                }
            }
        }
    }
}

private struct FanCard: View {
    let speed: Int, limit: Int
    var body: some View {
        GlassCard {
            HStack {
                Image(systemName: "fan")
                    .font(.title2)
                    .symbolEffect(.variableColor, isActive: speed > 0)
                VStack(alignment: .leading) {
                    Text("🌀 Вентилятор")
                    Text("\(speed)% • Лимит: \(limit)%")
                        .font(.caption).foregroundColor(.secondary)
                }
                Spacer()
                ProgressView(value: Double(speed), total: 100)
                    .frame(width: 60)
            }
        }
    }
}

private struct SafetySection: View {
    let waterOk: Bool, lidClosed: Bool, doorClosed: Bool
    var body: some View {
        GlassCard {
            HStack(spacing: 16) {
                StatusIcon(systemName: "drop", title: "Вода", ok: waterOk)
                StatusIcon(systemName: "lock.shield", title: "Крышка", ok: lidClosed)
                StatusIcon(systemName: "door.left.hand.closed", title: "Дверь", ok: doorClosed)
            }
        }
    }
}

private struct StatusIcon: View {
    let systemName: String, title: String
    let ok: Bool
    var body: some View {
        VStack {
            Image(systemName: systemName)
                .font(.title2)
                .foregroundColor(ok ? .green : .red)
            Text(title).font(.caption2)
        }
    }
}

private struct TipsView: View {
    let tips: BrooderParser.TipsContent
    @Binding var selectedTab: Int
    
    var body: some View {
        GlassCard {
            VStack(spacing: 8) {
                Text("📋 Советы и уход")
                    .font(.headline).frame(maxWidth: .infinity, alignment: .leading)
                Picker("", selection: $selectedTab) {
                    Text("📍 Сейчас").tag(0)
                    Text("⏪ Прошлые").tag(1)
                    Text("⏩ Будущие").tag(2)
                    Text("💡 Ротация").tag(3)
                }
                .pickerStyle(.segmented)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(currentTips, id: \.text) { tip in
                            TipCard(tip: tip)
                        }
                        if currentTips.isEmpty {
                    Text("Нет советов на этот день").font(.caption).foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private var currentTips: [BrooderParser.TipItem] {
        switch selectedTab {
        case 0: return tips.current ?? []
        case 1: return tips.past ?? []
        case 2: return tips.future ?? []
        case 3: return tips.rotating?.map { BrooderParser.TipItem(day: 0, text: $0, type: "rotating") } ?? []
        default: return []
        }
    }
}

private struct TipCard: View {
    let tip: BrooderParser.TipItem
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("День \(tip.day > 0 ? "\(tip.day)" : "")")
                .font(.caption2).foregroundColor(.yellow)
            Text(tip.text)
                .font(.caption)
                .lineLimit(3)
        }
        .padding(8)
        .background(Color.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
        .frame(width: 160)
    }
}

private struct RelayGrid: View {
    let relayStates: [Bool]
    let isAuto: Bool
    @ObservedObject var device: BrooderDevice
    let names = ["L1 ШИМ", "L2", "L3", "L4", "💡 СВЕТ"]
    
    var body: some View {
        GlassCard {
            Text("⚡ Нагрев / Свет")
                .font(.headline).frame(maxWidth: .infinity, alignment: .leading)
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 5), spacing: 12) {
                ForEach(0..<5, id: \.self) { idx in
                    RelayButton(title: names[idx], isActive: relayStates[idx], disabled: isAuto) {
                        device.setRelay(index: idx, state: !relayStates[idx])
                    }
                }
            }
        }
    }
}

private struct RelayButton: View {
    let title: String
    let isActive: Bool
    let disabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Circle().fill(isActive ? .green : .gray.opacity(0.3))
                    .frame(width: 12, height: 12)
                Text(title).font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(isActive ? Color.green.opacity(0.15) : Color.gray.opacity(0.1))
            .cornerRadius(8)
            .disabled(disabled)
            .opacity(disabled ? 0.5 : 1.0)
        }
    }
}

private struct ManualControlCard: View {
    let relays: [Bool]
    @ObservedObject var device: BrooderDevice
    
    var body: some View {
        GlassCard {
            Text("🎛 Ручное управление").font(.headline).frame(maxWidth: .infinity, alignment: .leading)
            HStack {
                ForEach(0..<5, id: \.self) { idx in
                    Toggle("", isOn: .init(
                        get: { relays[idx] },
                        set: { device.setRelay(index: idx, state: $0) }
                    ))
                    .toggleStyle(.switch)
                    .labelsHidden()
                }
            }
            .padding(.horizontal, 8)
        }
    }
}

private struct AlarmBanner: View {
    let isPanic: Bool
    let events: [String]
    var body: some View {
        HStack {
            Image(systemName: isPanic ? "speaker.wave.3.fill" : "exclamationmark.triangle.fill")
                .foregroundColor(.white)
            VStack(alignment: .leading) {
                Text("⚠️ АВАРИЯ В СИСТЕМЕ")
                    .fontWeight(.bold)
                Text(events.joined(separator: ", "))
                    .font(.caption)
            }
            .foregroundColor(.white)
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing),
            in: RoundedRectangle(cornerRadius: 12)
        )
        .shadow(color: .red.opacity(0.4), radius: 10, y: 5)
    }
}

// MARK: - GlassCard Modifiers
extension View {
    func glassBackground() -> some View {
        modifier(GlassCardModifier())
    }
}
struct GlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.15), lineWidth: 1))
            .foregroundStyle(.white)
    }
}

private extension View {
    func GlassCard(@ViewBuilder content: () -> some View) -> some View {
        content()
            .modifier(GlassCardModifier())
    }
}