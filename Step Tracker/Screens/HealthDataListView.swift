//
//  HealthDataListView.swift
//  Step Tracker
//
//  Created by Арсений Простаков on 16.08.2024.
//

import SwiftUI

struct HealthDataListView: View {
    @Environment(HealthKitData.self) private var hkData
    @Environment(HealthKitManager.self) private var hkManager
    @Namespace var zoomTransition
    @State private var isShowingAddData = false
    @State private var addDataDate: Date = .now
    @State private var valuetoAdd: String = ""
    @State private var isShowingAlert = true
    @State private var writeError: STError = .noData
    var metric: HealthMetricContext
    var listData: [HealthMetric] {
        metric == .steps ? hkData.stepData : hkData.weightData
    }
    var metricColor: Color {
        metric == .steps ? .pink : .indigo
    }
    var body: some View {
        List(listData.reversed()) { data in
            LabeledContent {
                Text(data.value, format: .number.precision(.fractionLength(metric == .steps ? 0 : 1)))
            } label: {
                Text(data.date, format: .dateTime.day().month().year())
                    .accessibilityLabel(data.date.accessibilityDate)
            }
            .listRowBackground(Color(.secondarySystemBackground).opacity(0.35))
            .accessibilityElement(children: .combine)
        }
        .navigationTitle(metric.title)
        .scrollContentBackground(.hidden)
        .background(LinearGradient(colors: [metricColor.opacity(0.25), .clear], startPoint: .topLeading, endPoint: .bottomTrailing))
        .sheet(isPresented: $isShowingAddData) {
            if #available(iOS 26, *) {
                addDataView
                    .presentationDetents([.fraction(0.4)])
                    .scrollContentBackground(.hidden)
                    .navigationTransition(.zoom(sourceID: "addData", in: zoomTransition))
            } else {
                addDataView
                    .presentationDetents([.fraction(0.4)])
            }
        }
        .overlay {
            if listData.isEmpty {
                ContentUnavailableView("No \(metric.title) to Display", image: metric == .steps ? "figure.walk" : "figure")
            }
        }
        .toolbar {
            if #available(iOS 26, *) {
                ToolbarItem {
                    Button("Add Data", systemImage: "plus") {
                        isShowingAddData = true
                    }
                    .buttonStyle(.glassProminent)
                    .tint(metricColor)
                }
                .matchedTransitionSource(id: "addData", in: zoomTransition)
            } else {
                ToolbarItem {
                    Button("Add Data", systemImage: "plus") {
                        isShowingAddData = true
                    }
                }
            }
        }
    }
    var addDataView: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $addDataDate, displayedComponents: .date)
                LabeledContent(metric.title) {
                    TextField("Value", text: $valuetoAdd)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 140)
                        .keyboardType(metric == .steps ? .numberPad : .decimalPad)
                }
            }
            .navigationTitle(metric.title)
            .toolbarTitleDisplayMode(.inline)
            .alert(isPresented: $isShowingAlert, error: writeError) { writeError in
                switch writeError {
                case .authNotDetermined, .noData, .unableToCompleteRequest, .invalidValue:
                    EmptyView()
                case .sharingDenied(_):
                    Button("Settings") {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }
                    Button("Cancel", role: .cancel) { }
                }
            } message: { writeError in
                Text(writeError.failureReason)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if #available(iOS 26.0, *) {
                        Button(role: .cancel) {
                            isShowingAddData = false
                        }
                        .tint(metricColor)
                    } else {
                        Button("Dismiss") {
                            isShowingAddData = false
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if #available(iOS 26.0, *) {
                        Button(role: .confirm) {
                            addDataToHealthKit()
                        }
                        .tint(metricColor)
                    } else {
                        Button("Add Data") {
                            addDataToHealthKit()
                        }
                    }
                }
            }
        }
    }
    private func addDataToHealthKit() {
        guard let value = Double(valuetoAdd) else {
            writeError = .invalidValue
            isShowingAlert = true
            valuetoAdd = ""
            return
        }
        Task {
            do {
                if metric == .steps {
                    try await hkManager.addStepData(for: addDataDate, value: value)
                    hkData.stepData = try await hkManager.fetchStepCount()
                } else {
                    try await hkManager.addWeightData(for: addDataDate, value: value)
                    async let weightsForLineChart = hkManager.fetchWeights(daysBack: 28)
                    async let weightsForBarChart = hkManager.fetchWeights(daysBack: 29)
                    
                    hkData.weightData = try await weightsForLineChart
                    hkData.weightDiffData = try await weightsForBarChart
                }
                isShowingAddData = false
            } catch STError.sharingDenied(let quantityType) {
                writeError = .sharingDenied(quantityType: quantityType)
                isShowingAlert = true
            } catch {
                writeError = .unableToCompleteRequest
                isShowingAlert = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        HealthDataListView(metric: .steps)
            .environment(HealthKitManager())
    }
}
