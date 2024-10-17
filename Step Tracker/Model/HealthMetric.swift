//
//  HealthMetric.swift
//  Step Tracker
//
//  Created by Арсений Простаков on 30.08.2024.
//

import Foundation

struct HealthMetric: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}
