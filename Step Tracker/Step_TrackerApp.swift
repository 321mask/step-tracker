//
//  Step_TrackerApp.swift
//  Step Tracker
//
//  Created by Арсений Простаков on 13.08.2024.
//

import SwiftUI

@main
struct Step_TrackerApp: App {
    let hkData = HealthKitData()
    let hkManager = HealthKitManager()
    var body: some Scene {
        WindowGroup {
            DashboardView()
                .environment(hkData)
                .environment(hkManager)
        }
    }
}
