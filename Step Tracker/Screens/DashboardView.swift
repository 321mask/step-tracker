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
    @Environment(HealthKitData.self) private var hkData
    @Environment(HealthKitManager.self) private var hkManager
    @State private var isShowingPermissionPriming = false
    @State private var selectedStat: HealthMetricContext = .steps
    @State private var isShowingAlert = false
    @State private var fetchError: STError = .noData
    
    var metricColor: Color {
        selectedStat == .steps ? .pink : .indigo
    }
    
    var navbarTint: Color {
        if #available(iOS 26.0, *) {
            return .primary
        } else {
            return metricColor
        }
    }
    
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
                        StepBarChart(chartData: ChartHelper.convert(data: hkData.stepData))
                        StepPieChart(chartData: ChartHelper.averageWeekdayCount(for: hkData.stepData))
                    case .weight:
                        WeightLineChart(chartData: ChartHelper.convert(data: hkData.weightData))
                        WeightBarChart(chartData: ChartHelper.averageDailyWeightDiff(for: hkData.weightDiffData))
                    }
                }
                .padding()
            }
            .task { await fetchHealthDataAsync() }
            .navigationTitle("Dashboard")
            .toolbarTitleDisplayMode(.inlineLarge)
            .background(LinearGradient(colors: [metricColor.opacity(0.25), .clear], startPoint: .topLeading, endPoint: .bottomTrailing))
            .navigationDestination(for: HealthMetricContext.self) { metric in HealthDataListView(metric: metric)
            }
            .refreshable {
                await fetchHealthDataAsync()
            }
            .fullScreenCover(isPresented: $isShowingPermissionPriming, onDismiss: { Task { await fetchHealthDataAsync() } }, content: { HealthKitPermissionPrimingView() })
            .alert(isPresented: $isShowingAlert, error: fetchError) { fetchError in
                // Actions
                Button("Retry") {
                    isShowingPermissionPriming = true
                    Task { await fetchHealthDataAsync() }
                }
            } message: { fetchError in
                Text(fetchError.failureReason)
            }
        }
        .tint(navbarTint)
    }
    @MainActor
    private func fetchHealthDataAsync() async {
            do {
                async let steps = hkManager.fetchStepCount()
                async let weightsForLineChart = hkManager.fetchWeights(daysBack: 28)
                async let weightsForBarChart = hkManager.fetchWeights(daysBack: 29)
                
                hkData.stepData = try await steps
                hkData.weightData = try await weightsForLineChart
                hkData.weightDiffData = try await weightsForBarChart
            } catch STError.authNotDetermined {
                isShowingPermissionPriming = true
            } catch STError.noData {
                fetchError = .noData
                isShowingAlert = true
            } catch STError.sharingDenied(let quantityType) {
                print("sharing denied for \(quantityType)")
            } catch {
                fetchError = .unableToCompleteRequest
                isShowingAlert = true
            }
    }
}

#Preview {
    DashboardView()
        .environment(HealthKitManager())
        .environment(HealthKitData())
}
