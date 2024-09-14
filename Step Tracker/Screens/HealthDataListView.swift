//
//  HealthDataListView.swift
//  Step Tracker
//
//  Created by Арсений Простаков on 16.08.2024.
//

import SwiftUI

struct HealthDataListView: View {
    @Environment(HealthKitManager.self) private var hkManager
    @State var isShowingAddData = false
    @State var addDataDate: Date = .now
    @State var valuetoAdd: String = ""
    var metric: HealthMetricContext
    var listData: [HealthMetric] {
        metric == .steps ? hkManager.stepData : hkManager.weightData
    }
    var body: some View {
        List(listData.reversed()) { data in
            HStack {
                Text(data.date, format: .dateTime.day().month().year())
                Spacer()
                Text(data.value, format: .number.precision(.fractionLength(metric == .steps ? 0 : 1)))
            }
        }
        .navigationTitle(metric.title)
        .sheet(isPresented: $isShowingAddData) {
            addDataView
        }
        .toolbar {
            Button("Add Data", systemImage: "plus") {
                isShowingAddData = true
            }
        }
    }
    var addDataView: some View {
        NavigationStack {
            Form {
                DatePicker("Date", selection: $addDataDate, displayedComponents: .date)
                HStack {
                    Text(metric.title)
                    Spacer()
                    TextField("Value", text: $valuetoAdd)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 140)
                        .keyboardType(metric == .steps ? .numberPad : .decimalPad)
                }
            }
            .navigationTitle(metric.title)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Dismiss") {
                        isShowingAddData = false
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Data") {
                        Task {
                            if metric == .steps {
                                await hkManager.addStepData(for: addDataDate, value: Double(valuetoAdd) ?? 0.0)
                                await hkManager.fetchStepCount()
                                isShowingAddData = false
                            } else {
                                await hkManager.addWeightData(for: addDataDate, value: Double(valuetoAdd) ?? 0.0)
                                await hkManager.fetchweightCount()
                                await hkManager.fetchweightForDiffentials()
                                isShowingAddData = false
                            }
                        }
                    }
                }
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
