//
//  ChartDataTypes.swift
//  Step Tracker
//
//  Created by Арсений Простаков on 10.09.2024.
//

import Foundation

struct WeekdayChartData: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let value: Double
}
