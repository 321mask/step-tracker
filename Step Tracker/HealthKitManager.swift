//
//  HealthKitManager.swift
//  Step Tracker
//
//  Created by Арсений Простаков on 23.08.2024.
//

import Foundation
import Observation
import HealthKit

@Observable class HealthKitManager {
    let store = HKHealthStore()
    
    let types: Set = [HKQuantityType(.stepCount), HKQuantityType(.bodyMass)]
}
