//
//  ChartContainer.swift
//  Step Tracker
//
//  Created by Арсений Простаков on 07.10.2024.
//

import SwiftUI

struct ChartContainerCongiguration {
    let title: String
    let symbol: String
    let subtitle: String
    let context: HealthMetricContext
    let isNav: Bool
}
struct ChartContainer<Content: View>: View {
    let config: ChartContainerCongiguration
    @ViewBuilder var content: () -> Content
    var body: some View {
        VStack(alignment: .leading) {
            if config.isNav {
                navigationLinkView
            } else {
                titleView
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 12)
            }
            content()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
    var titleView: some View {
        VStack(alignment: .leading) {
            Label(config.title, systemImage: config.symbol)
                .font(.title3.bold())
                .foregroundStyle(config.context == .steps ? .pink : .indigo)
            Text(config.subtitle)
                .font(.caption)
        }
    }
    var navigationLinkView: some View {
        NavigationLink(value: config.context) {
            HStack {
                VStack(alignment: .leading) {
                    Label(config.title, systemImage: config.symbol)
                        .font(.title3.bold())
                        .foregroundStyle(config.context == .steps ? .pink : .indigo)
                    Text(config.subtitle)
                        .font(.caption)
                }
                Spacer()
                Image(systemName: "chevron.right")
            }
        }
    }
}

#Preview {
    ChartContainer(config: .init(title: "Steps", symbol: "figure.walk", subtitle: "Last 7 days", context: .steps, isNav: false)) {
        Text("Chart goes here")
            .frame(minHeight: 150)
    }
}
