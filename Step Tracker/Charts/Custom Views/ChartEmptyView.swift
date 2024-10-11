//
//  ChartEmptyView.swift
//  Step Tracker
//
//  Created by Арсений Простаков on 07.10.2024.
//

import SwiftUI

struct ChartEmptyView: View {
    let systemImageName: String
    let title: String
    let discription: String
    var body: some View {
        ContentUnavailableView {
            Image(systemName: systemImageName)
                .resizable()
                .frame(width: 32, height: 32)
                .padding(.bottom, 8)
            
            Text(title)
                .font(.callout.bold())
            
            Text(discription)
                .font(.footnote)
        }
        .foregroundStyle(.secondary)
        .offset(y: -12)
    }
}

#Preview {
    ChartEmptyView(systemImageName: "", title: "", discription: "")
}
