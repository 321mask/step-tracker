//
//  WeightLineChart.swift
//  Step Tracker
//
//  Created by Арсений Простаков on 12.09.2024.
//

import SwiftUI
import Charts

struct WeightLineChart: View {
    @State private var rawSelectedDate: Date?
    @State private var selectedDay: Date?
    var averageWeight: Double {
        chartData.map { $0.value }.average
    }
    var selectedData: DateValueChartData? {
        ChartHelper.parseSelectedData(from: chartData, in: rawSelectedDate)
    }
    var chartData: [DateValueChartData]
    var minValue: Double {
        chartData.map { $0.value }.min() ?? 0
    }
    
    var body: some View {
        ChartContainer(chartType: .weightLine(average: averageWeight)) {
            Chart {
                if let selectedData {
                    ChartAnnotationView(data: selectedData, context: .weight)
                }
                RuleMark(y: .value("Goal", 155))
                    .foregroundStyle(.mint)
                    .lineStyle(.init(lineWidth: 1, dash: [5]))
                ForEach(chartData) { weight in
                    AreaMark(x: .value("Day", weight.date, unit: .day),
                             yStart: .value("Value", weight.value),
                             yEnd: .value("Min Value", minValue))
                    .foregroundStyle(Gradient(colors: [.indigo.opacity(0.5), .clear]))
                    .interpolationMethod(.catmullRom)
                    LineMark(x: .value("Day", weight.date, unit: .day), y: .value("Value", weight.value))
                        .foregroundStyle(.indigo)
                        .interpolationMethod(.catmullRom)
                        .symbol(.circle)
                }
            }
            .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
            .frame(height: 150)
            .chartYScale(domain: .automatic(includesZero: false))
            .chartXAxis {
                AxisMarks {
                    AxisValueLabel(format: .dateTime.month(.defaultDigits).day())
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                        .foregroundStyle(Color.secondary.opacity(0.3))
                    AxisValueLabel()
                }
            }
            .overlay {
                if chartData.isEmpty {
                    ChartEmptyView(systemImageName: "chart.line.downtrend.xyaxis", title: "No Data", discription: "There is no weight data from the Health App.")
                }
            }
            
        }
        .sensoryFeedback(.selection, trigger: selectedDay)
        .onChange(of: rawSelectedDate) { oldValue, newValue in
            if oldValue?.weekdayInt != newValue?.weekdayInt {
                selectedDay = newValue
            }
        }
    }
}

#Preview {
    WeightLineChart(chartData: ChartHelper.convert(data: MockData.weights))
}
