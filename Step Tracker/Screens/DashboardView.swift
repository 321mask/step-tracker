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
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                    
                    VStack(alignment: .leading) {
                            VStack(alignment: .leading) {
                                Label("Averages", systemImage: "calendar")
                                    .font(.title3.bold())
                                    .foregroundStyle(.pink)
                                Text("Last 28 days")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        
                        RoundedRectangle(cornerRadius: 12)
                            .foregroundStyle(.secondary)
                            .frame(height: 240)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
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
