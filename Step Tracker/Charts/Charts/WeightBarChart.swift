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
    @State private var selectedDay: Date?
    var chartData: [DateValueChartData]
    var selectedData: DateValueChartData? {
        ChartHelper.parseSelectedData(from: chartData, in: rawSelectedDate)
    }
    
    var body: some View {
        ChartContainer(chartType: .weightDiffBar) {
            Chart {
                if let selectedData {
                    ChartAnnotationView(data: selectedData, context: .weight)
                }
                ForEach(chartData) { weight in
                    Plot {
                        BarMark(x: .value("Date", weight.date),
                                y: .value("Weight change", weight.value))
                        .foregroundStyle(weight.value >= 0 ? Color.indigo.gradient : Color.mint.gradient)
                    }
                    .accessibilityLabel(weight.date.weekdayTitle)
                    .accessibilityValue("\(weight.value.formatted(.number.precision(.fractionLength(1)).sign(strategy: .always))) kilograms")
                }
            }
            .frame(height: 150)
            .chartXSelection(value: $rawSelectedDate.animation(.easeInOut))
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) {
                    AxisValueLabel(format: .dateTime.weekday(), centered: true)
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                        .foregroundStyle(Color.secondary.opacity(0.3))
                    AxisValueLabel()
                }
            }
            if chartData.isEmpty {
                ChartEmptyView(systemImageName: "chart.bar", title: "No Data", discription: "There is no weight data from the Health App.")
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
    WeightBarChart(chartData: ChartHelper.convert(data: MockData.weightDiffs))
}
