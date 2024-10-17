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
    @State private var isShowingPermissionPriming = false
    @State private var selectedStat: HealthMetricContext = .steps
    @State private var isShowingAlert = false
    @State private var fetchError: STError = .noData
    
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
                    switch selectedStat {
                    case .steps:
                        StepBarChart(chartData: ChartHelper.convert(data: hkManager.stepData))
                        StepPieChart(chartData: ChartHelper.averageWeekdayCount(for: hkManager.stepData))
                    case .weight:
                        WeightLineChart(chartData: ChartHelper.convert(data: hkManager.weightData))
                        WeightBarChart(chartData: ChartHelper.averageDailyWeightDiff(for: hkManager.weightDiffData))
                    }
                }
            }
            .padding()
            .task { fetchHelthData() }
            .navigationTitle("Dashboard")
            .navigationDestination(for: HealthMetricContext.self) { metric in HealthDataListView(metric: metric)
            }
            .fullScreenCover(isPresented: $isShowingPermissionPriming, onDismiss: { fetchHelthData() }, content: { HealthKitPermissionPrimingView() })
            .alert(isPresented: $isShowingAlert, error: fetchError) { fetchError in
                // Actions
            } message: { fetchError in
                Text(fetchError.failureReason)
            }
        }
        .tint(selectedStat == .steps ? .pink : .indigo)
    }
    private func fetchHelthData() {
        Task {
            do {
                async let steps = hkManager.fetchStepCount()
                async let weightsForLineChart = hkManager.fetchWeights(daysBack: 28)
                async let weightsForBarChart = hkManager.fetchWeights(daysBack: 29)
                
                hkManager.stepData = try await steps
                hkManager.weightData = try await weightsForLineChart
                hkManager.weightDiffData = try await weightsForBarChart
//                await hkManager.addSimulatorData()
            } catch STError.authNotDetermined {
                isShowingPermissionPriming = true
            } catch STError.noData {
                fetchError = .noData
                isShowingAlert = true
            } catch STError.sharingDenied(let quantityType) {
                print("sharin denied for \(quantityType)")
            } catch {
                fetchError = .unableToCompleteRequest
                isShowingAlert = true
            }
        }
    }
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
}
