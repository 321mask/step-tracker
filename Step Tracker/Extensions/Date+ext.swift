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
}
