//
//  DashboardWatchView.swift
//  GiaVang Watch App
//
//  Created by ORL on 20/10/25.
//

import SwiftUI

struct DashboardWatchView: View {
    
    @StateObject private var viewModel = CurrencyViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Header
                VStack(spacing: 4) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)

                    Text("Dashboard")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                .padding(.top, 8)

                Divider()

                // Quick Stats
                VStack(spacing: 8) {
                    StatRow(
                        icon: "circle.hexagongrid.fill",
                        title: "Vàng SJC",
                        value: "94.5M",
                        color: .yellow
                    )

                    StatRow(
                        icon: "dollarsign.circle.fill",
                        title: "USD",
                        value: "25,450",
                        color: .green
                    )

                    StatRow(
                        icon: "chart.bar.fill",
                        title: "Thị trường",
                        value: "Tăng",
                        color: .blue
                    )
                }
                .padding(.horizontal, 8)
            }
            .padding(.bottom, 8)
        }
    }
}

struct StatRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }

            Spacer()
        }
        .padding(8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    DashboardWatchView()
}
