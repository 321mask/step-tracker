//
//  Step_Tracker_Tests.swift
//  Step Tracker Tests
//
//  Created by Арсений Простаков on 17.10.2024.
//

import Testing
@testable import Step_Tracker
import Foundation

struct Step_Tracker_Tests {

    @Test func arrayAverage() async throws {
        let array: [Double] = [1.5, 2.6, 3.7, 4.8]
        #expect(array.average == 3.15)
    }
    
    @Suite("Chart Helper Tests") struct ChartHelperTests {
        var metrics: [HealthMetric] = [
            .init(date: Calendar.current.date(from: .init(year: 2024, month: 10, day: 14))!, value: 1000), //Monday
            .init(date: Calendar.current.date(from: .init(year: 2024, month: 10, day: 15))!, value: 500), //Tuesday
            .init(date: Calendar.current.date(from: .init(year: 2024, month: 10, day: 16))!, value: 250), //Wednesday
            .init(date: Calendar.current.date(from: .init(year: 2024, month: 10, day: 21))!, value: 750) //Monday
        ]
        var weightMetrics: [HealthMetric] = [
            .init(date: Calendar.current.date(from: .init(year: 2024, month: 10, day: 14))!, value: 70), //Monday
            .init(date: Calendar.current.date(from: .init(year: 2024, month: 10, day: 15))!, value: 72), //Tuesday
            .init(date: Calendar.current.date(from: .init(year: 2024, month: 10, day: 16))!, value: 71), //Wednesday
            .init(date: Calendar.current.date(from: .init(year: 2024, month: 10, day: 21))!, value: 69) //Monday
        ]
        
        @Test func averageWeekdayCount() {
            let averageWeekdayCount = ChartHelper.averageWeekdayCount(for: metrics)
            #expect(averageWeekdayCount.count == 3)
            #expect(averageWeekdayCount[0].value == 875)
            #expect(averageWeekdayCount[1].value == 500)
            #expect(averageWeekdayCount[2].date.weekdayTitle == "Wednesday")
        }
        @Test func averageDailyWeightDiff() {
            let averageDailyWeightDiff = ChartHelper.averageDailyWeightDiff(for: weightMetrics)
            #expect(averageDailyWeightDiff.count == 3)
            #expect(averageDailyWeightDiff[1].value == 2)
            #expect(averageDailyWeightDiff[2].value == -1)
            #expect(averageDailyWeightDiff[2].date.weekdayInt == 4)
        }
    }
}
