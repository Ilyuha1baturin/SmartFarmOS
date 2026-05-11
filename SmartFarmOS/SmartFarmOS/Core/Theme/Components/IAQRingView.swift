//
//  IAQRingView.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import SwiftUI

struct IAQRingView: View {
    @Binding var value: Double
    var size: CGFloat = 120
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.12), lineWidth: 10)
            
            Circle()
                .trim(from: 0, to: max(min(value, 100) / 100, 0.01))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [.accent, .warning, .danger]),
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            
            VStack(spacing: 2) {
                Text("IAQ")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.textSecondary)
                Text(String(format: "%.0f", value))
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(statusColor)
                Text(statusText)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(statusColor)
                    .textCase(.uppercase)
            }
        }
        .frame(width: size, height: size)
    }
    
    private var statusColor: Color {
        if value > 75 { return .danger }
        if value > 50 { return .warning }
        return .accent
    }
    
    private var statusText: String {
        if value > 75 { return "Критично" }
        if value > 50 { return "Внимание" }
        return "Норма"
    }
}

#Preview {
    struct Preview: View {
        @State var iaq: Double = 42
        var body: some View {
            IAQRingView(value: $iaq)
                .glassCard()
                .preferredColorScheme(.dark)
        }
    }
    Preview()
}