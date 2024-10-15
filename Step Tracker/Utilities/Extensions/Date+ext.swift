//
//  Date+ext.swift
//  Step Tracker
//
//  Created by Арсений Простаков on 10.09.2024.
//

import Foundation

extension Date {
    var weekdayInt: Int {
        Calendar.current.component(.weekday, from: self)
    }
    var weekdayTitle: String {
        self.formatted(.dateTime.weekday(.wide))
    }
    var accessibilityDate: String {
        self.formatted(.dateTime.month(.wide).day())
    }
}
