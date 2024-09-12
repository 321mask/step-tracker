//
//  WeightBarChart.swift
//  Step Tracker
//
//  Created by Арсений Простаков on 12.09.2024.
//

import SwiftUI
import Charts

struct WeightBarChart: View {
    @State private var rawSelectedDate: Date?
    var selectedStat: HealthMetricContext
    var chartData: [HealthMetric]
    var selectedHealthMetric: HealthMetric? {
        guard let rawSelectedDate else { return nil }
        return chartData.first {
            Calendar.current.isDate(rawSelectedDate, inSameDayAs: $0.date) }
    }
    var body: some View {
        VStack {
            NavigationLink(value: selectedStat) {
                HStack {
                    VStack(alignment: .leading) {
                        Label("Average Weight Change", systemImage: "figure")
                            .font(.title3.bold())
                            .foregroundStyle(.indigo)
                        Text("Per Weekday (Last 28 Days)")
                            .font(.caption)
                    }
                }
            }
            Chart {
                ForEach(chartData) { weight in
                    BarMark(x: .value("Date", weight.date),
                            y: .value("Weight change", weight.value))
                    .foregroundStyle(Color.indigo.gradient)
                    .opacity(rawSelectedDate == nil || weight.date == selectedHealthMetric?.date ? 1.0 : 0.3)
                }
            }
            .frame(height: 150)
            .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
            .chartXAxis {
                AxisMarks {
                    AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                        .foregroundStyle(Color.secondary.opacity(0.3))
                    AxisValueLabel((value.as(Double.self) ?? 0).formatted(.number.notation(.compactName)))
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
}

#Preview {
    WeightBarChart(selectedStat: .weight, chartData: MockData.weights)
}
