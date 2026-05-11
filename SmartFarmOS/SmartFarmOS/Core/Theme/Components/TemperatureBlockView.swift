//
//  TemperatureBlockView.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import SwiftUI

struct TemperatureBlockView: View {
    @Binding var current: Double
    @Binding var target: Double
    @Binding var isAlarm: Bool
    @Binding var isWarning: Bool
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .bottom, spacing: 2) {
                    Text(current.isValidValue ? String(format: "%.1f", current) : "--")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(statusColor)
                    Text("°C")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(statusColor.opacity(0.8))
                }
                
                Text("Цель: \(String(format: "%.1f", target)) °C")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.textSecondary)
                
                // Прогресс-бар (шкала 15..45°C как в прошивке)
                let progress = min(max((current.isValidValue ? current : target) - 15, 0) / 30.0, 1.0)
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.gray.opacity(0.15)).frame(height: 6)
                    Capsule().fill(statusGradient)
                        .frame(width: max(geo.size.width * progress, 6), height: 6)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 120)
    }
    
    private var statusColor: Color {
        if isAlarm { return .danger }
        if isWarning { return .warning }
        return .accent
    }
    
    private var statusGradient: LinearGradient {
        LinearGradient(
            colors: isAlarm ? [.danger, .red] : [.accent, .green],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

private extension Double {
    var isValidValue: Bool { self > -900 } // Фильтр заглушек -999 из main.cpp
}

#Preview {
    struct Preview: View {
        @State var cur: Double = 24.5
        @State var tgt: Double = 33.0
        @State var alarm = false
        @State var warn = false
        var body: some View {
            TemperatureBlockView(current: $cur, target: $tgt, isAlarm: $alarm, isWarning: $warn)
                .glassCard()
                .padding()
                .preferredColorScheme(.dark)
        }
    }
    Preview()
}