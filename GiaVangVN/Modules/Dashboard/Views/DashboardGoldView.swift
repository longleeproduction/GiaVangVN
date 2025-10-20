//
//  DashboardGoldView.swift
//  GiaVangVN
//
//  Created by L7 Mobile on 16/10/25.
//

import SwiftUI
import Charts

struct DashboardGoldView: View {

    @EnvironmentObject private var viewModel: DashBoardViewModel

    var body: some View {
        VStack {
            if viewModel.isLoadingListSJC {
                ProgressView()

            } else {
                if let data = viewModel.listSJC {
                    buildChart(data: data)
                } else {
                    Button {
                        viewModel.getListPriceSJC()
                    } label: {
                        Label("Refresh", systemImage: "arrow.2.circlepath.circle")
                    }
                }
            }
        }.frame(maxWidth: .infinity)
            .frame(height: 400)
    }


    @ViewBuilder
    func buildChart(data: GoldListData) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text(data.title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(data.subTitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)

            // Chart
            let chartData = prepareChartData(from: data.list)

            if chartData.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("Không có dữ liệu biểu đồ")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Chart {
                    // Buy price line
                    ForEach(chartData) { item in
                        LineMark(
                            x: .value("Ngày", item.date),
                            y: .value("Mua vào", item.buyPrice)
                        )
                        .foregroundStyle(.green)
                        .symbol(Circle())
                        .interpolationMethod(.catmullRom)
                    }

                    // Sell price line
                    ForEach(chartData) { item in
                        LineMark(
                            x: .value("Ngày", item.date),
                            y: .value("Bán ra", item.sellPrice)
                        )
                        .foregroundStyle(.red)
                        .symbol(Circle())
                        .interpolationMethod(.catmullRom)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        if let dateString = value.as(String.self) {
                            AxisValueLabel {
                                Text(dateString)
                                    .font(.caption2)
                                    .rotationEffect(.degrees(-45))
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let price = value.as(Double.self) {
                                Text(formatPrice(price))
                                    .font(.caption2)
                            }
                        }
                        AxisGridLine()
                    }
                }
                .chartLegend(position: .bottom) {
                    HStack(spacing: 20) {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(.green)
                                .frame(width: 8, height: 8)
                            Text("Mua vào")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        HStack(spacing: 4) {
                            Circle()
                                .fill(.red)
                                .frame(width: 8, height: 8)
                            Text("Bán ra")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
            }
        }
    }

    // MARK: - Helper Methods

    private func prepareChartData(from items: [GoldListItem]) -> [ChartDataPoint] {
        var chartData: [ChartDataPoint] = []

        for item in items {
            // Decrypt buy and sell prices
            let buyPriceString = ApiDecryptor.decrypt(item.buy)
            let sellPriceString = ApiDecryptor.decrypt(item.sell)
            guard let buyPrice = Double(buyPriceString), let sellPrice = Double(sellPriceString) else {
                continue
            }

            // Format date for display
            let displayDate = formatDateForChart(item.dateUpdate)

            let dataPoint = ChartDataPoint(
                id: item.id,
                date: displayDate,
                buyPrice: buyPrice,
                sellPrice: sellPrice,
                dateUpdate: item.dateUpdate
            )

            chartData.append(dataPoint)
        }

        // Sort by date (oldest to newest)
        return chartData.sorted { $0.dateUpdate < $1.dateUpdate }
    }

    private func formatDateForChart(_ dateString: String) -> String {
        // Input: "09:01:00 16/10/2025"
        // Output: "16/10"
        let components = dateString.split(separator: " ")
        guard components.count >= 2 else { return dateString }

        let dateComponents = components[1].split(separator: "/")
        guard dateComponents.count >= 2 else { return String(components[1]) }

        return "\(dateComponents[0])/\(dateComponents[1])"
    }

    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = ","

        if price >= 1_000_000 {
            let inMillions = price / 1_000_000
            return String(format: "%.1fM", inMillions)
        } else if price >= 1_000 {
            let inThousands = price / 1_000
            return String(format: "%.0fK", inThousands)
        } else {
            return formatter.string(from: NSNumber(value: price)) ?? "\(Int(price))"
        }
    }
}

// MARK: - Chart Data Model

struct ChartDataPoint: Identifiable {
    let id: String
    let date: String
    let buyPrice: Double
    let sellPrice: Double
    let dateUpdate: String
}

#Preview {
    DashboardGoldView()
}
