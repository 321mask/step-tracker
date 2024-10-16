//
//  ChartHelper.swift
//  Step Tracker
//
//  Created by Арсений Простаков on 08.10.2024.
//

import Foundation
import Algorithms

struct ChartHelper {
    /// Convert ``HealthMetric`` data to charts' data.
    /// - Parameter data: ``HealthMetric`` dates and values.
    /// - Returns: Charts' dates and values.
    static func convert(data: [HealthMetric]) -> [DateValueChartData] {
        data.map { .init(date: $0.date, value: $0.value)}
    }
    /// Parse data from an array of chart data to the chart data of a selected date.
    /// - Parameters:
    ///   - data: Array of chart data.
    ///   - selectedDate: User selected date.
    /// - Returns: Selected chart's date and value.
    static func parseSelectedData(from data: [DateValueChartData], in selectedDate: Date?) -> DateValueChartData? {
        guard let selectedDate else { return nil }
        return data.first {
            Calendar.current.isDate(selectedDate, inSameDayAs: $0.date) }
    }
    /// Average weekday step count.
    /// - Parameter metric: Array of ``HealthMetric`` data.
    /// - Returns: Array of chart data.
    static func averageWeekdayCount(for metric: [HealthMetric]) -> [DateValueChartData] {
        let sortedByWeekday = metric.sorted(using: KeyPathComparator(\.date.weekdayInt))
        let weekdayArray = sortedByWeekday.chunked { $0.date.weekdayInt == $1.date.weekdayInt }
        var weekdayChartData: [DateValueChartData] = []
        for array in weekdayArray {
            guard let firstValue = array.first else { continue }
            let total = array.reduce(0) { $0 + $1.value }
            let avgSteps = total/Double(array.count)
            weekdayChartData.append(.init(date: firstValue.date, value: avgSteps))
        }
        return weekdayChartData
    }
    /// Average daily weight difference.
    /// - Parameter weights: Array of ``HealthMetric`` data.
    /// - Returns: Array of chart data.
    static func averageDailyWeightDiff(for weights: [HealthMetric]) -> [DateValueChartData] {
        var diffValues: [(date: Date, value: Double)] = []
        guard weights.count > 1 else { return [] }
        for i in 1..<weights.count {
            let date = weights[i].date
            let diff = weights[i].value - weights[i - 1].value
            diffValues.append((date: date, value: diff))
        }
        var weekdayChartData: [DateValueChartData] = []
        let sortedByWeekday = diffValues.sorted(using: KeyPathComparator(\.date.weekdayInt))
        let weekdayArray = sortedByWeekday.chunked { $0.date.weekdayInt == $1.date.weekdayInt }
        for array in weekdayArray {
            guard let firstValue = array.first else { continue }
            let total = array.reduce(0) { $0 + $1.value }
            let avgWeightDiff = total/Double(array.count)
            weekdayChartData.append(.init(date: firstValue.date, value: avgWeightDiff))
        }
        return weekdayChartData
    }
}
