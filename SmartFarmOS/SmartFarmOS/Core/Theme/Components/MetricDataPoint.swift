//
//  MetricDataPoint.swift
//  SmartFarmOS
//
//  Created by Ilya Suyskiy on 11.05.2026.
//


import SwiftUI
import Charts

/// Точка истории для графиков (маппинг из history[] в main.cpp)
struct MetricDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    let target: Double
}

struct MetricChartView: View {
    @Binding var data: [MetricDataPoint]
    var title: String
    var unit: String
    var valueColor: Color = .accent
    var targetColor: Color = .textSecondary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.textPrimary)
            
            if data.isEmpty {
                Text("Нет данных")
                    .foregroundStyle(.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
            } else {
                Chart(Array(data.suffix(48))) { point in
                    LineMark(
                        x: .value("Time", point.date),
                        y: .value(unit, point.value)
                    )
                    .foregroundStyle(valueColor)
                    .lineStyle(StrokeStyle(lineWidth: 2.5, lineJoin: .round))
                    
                    if point.target != point.value {
                        LineMark(
                            x: .value("Time", point.date),
                            y: .value("Цель", point.target)
                        )
                        .foregroundStyle(targetColor.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5, 5]))
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                        AxisGridLine().foregroundStyle(Color.gray.opacity(0.15))
                        AxisValueLabel().foregroundStyle(.textSecondary)
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine().foregroundStyle(Color.gray.opacity(0.15))
                        AxisValueLabel().foregroundStyle(.textSecondary)
                    }
                }
                .chartXScale(domain: data.first?.date...data.last?.date ?? Date()...Date())
                .frame(height: 140)
            }
        }
    }
}

#Preview {
    struct Preview: View {
        @State var history: [MetricDataPoint] = []
        var body: some View {
            MetricChartView($history, title: "🌡 Температура", unit: "°C")
                .glassCard()
                .padding()
                .task {
                    let now = Date()
                    history = (0...24).map { i in
                        MetricDataPoint(
                            date: now.addingTimeInterval(-Double(24-i) * 3600),
                            value: 25 + Double.random(in: -2...3),
                            target: 33
                        )
                    }
                }
                .preferredColorScheme(.dark)
        }
    }
    Preview()
}