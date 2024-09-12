//
//  DashboardView.swift
//  Step Tracker
//
//  Created by Арсений Простаков on 13.08.2024.
//

import SwiftUI
import Charts

enum HealthMetricContext: CaseIterable, Identifiable {
    case steps, weight
    var id: Self { self }
    
    var title: String {
        switch self {
        case .steps: 
            return "Steps"
        case .weight: 
            return "Weight"
        }
    }

}

struct DashboardView: View {
    @Environment(HealthKitManager.self) private var hkManager
    @AppStorage("hasSeenPermissionPriming") private var hasSeenPermissionPriming = false
    @State private var isShowingPermissionPriming = false
    @State private var selectedStat: HealthMetricContext = .steps
    
    var isSteps: Bool { selectedStat == .steps }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Picker("Selected Stat", selection: $selectedStat) {
                        ForEach(HealthMetricContext.allCases) {
                            Text($0.title)
                        }
                    }
                    .pickerStyle(.segmented)
                    StepBarChart(selectedStat: selectedStat, chartData: hkManager.stepData)
                    StepPieChart(chartData: ChartMath.averageWeekdayCount(for: hkManager.stepData))
                }
            }
            .padding()
            .task {
                await hkManager.fetchStepCount()
                ChartMath.averageWeekdayCount(for: hkManager.stepData)
                isShowingPermissionPriming = !hasSeenPermissionPriming
            }
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetricContext.self) { metric in HealthDataListView(metric: metric)
            }
            .sheet(isPresented: $isShowingPermissionPriming, onDismiss: {}, content: { HealthKitPermissionPrimingView(hasSeen: $hasSeenPermissionPriming) })
        }
        .tint(isSteps ? .pink : .indigo)
    }
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
