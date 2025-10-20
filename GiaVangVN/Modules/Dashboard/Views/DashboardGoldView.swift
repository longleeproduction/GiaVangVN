//
//  DashboardGoldView.swift
//  GiaVangVN
//
//  Created by ORL on 16/10/25.
//

import SwiftUI
import Charts

struct DashboardGoldView: View {

    @EnvironmentObject private var viewModel: DashBoardViewModel
    @State private var selectedDate: String?

    var body: some View {
        VStack {
            if viewModel.isLoadingListSJC {
                ProgressView()

            } else {
                if let data = viewModel.listSJC {
                    buildChart(data: data)
                    HStack {
                        Text(viewModel.listSJC?.subTitle ?? "")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button {
                            viewModel.getListPriceSJC()
                        } label: {
                            Label("Refresh", systemImage: "arrow.2.circlepath.circle")
                        }
                    }
                }
            }
        }.frame(maxWidth: .infinity)
            .frame(height: 400)
    }


    @ViewBuilder
    func buildChart(data: GoldListData) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text(data.title)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal)

            // Chart
            let chartData = prepareChartData(from: data.list.reversed())

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
                let (minPrice, maxPrice) = calculatePriceRange(from: chartData)

                Chart {
                    // Buy price line
                    ForEach(chartData) { item in
                        LineMark(
                            x: .value("Ngày", item.date),
                            y: .value("Mua vào", item.buyPrice),
                            series: .value("Mua vào", "Mua vào")
                        )
                        .foregroundStyle(.green)
                        .symbol {
                            Circle()
                                .fill(.green)
                                .frame(width: 6, height: 6)
                        }
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .interpolationMethod(.catmullRom)
                    }

                    // Sell price line
                    ForEach(chartData) { item in
                        LineMark(
                            x: .value("Ngày", item.date),
                            y: .value("Bán ra", item.sellPrice),
                            series: .value("Bán ra", "Bán ra")
                        )
                        .foregroundStyle(.red)
                        .symbol {
                            Circle()
                                .fill(.red)
                                .frame(width: 6, height: 6)
                        }
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .interpolationMethod(.catmullRom)
                    }
                }
                .chartXAxis {
                    AxisMarks(preset: .aligned, values: .stride(by: .day, count: max(1, chartData.count / 3))) { value in
                        if let dateString = value.as(String.self) {
                            AxisValueLabel {
                                Text(dateString)
                                    .font(.system(size: 10))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                            AxisTick()
                            AxisGridLine()
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        if let price = value.as(Double.self), price > 0 {
                            AxisValueLabel {
                                Text(formatPrice(price))
                                    .font(.caption2)
                            }
                            AxisGridLine()
                        }
                    }
                }
                .chartYScale(domain: minPrice...maxPrice)
                .chartOverlay { proxy in
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(.clear)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let location = value.location
                                        if let date: String = proxy.value(atX: location.x) {
                                            selectedDate = date
                                        }
                                    }
                                    .onEnded { _ in
                                        // Keep selection visible for a moment
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            selectedDate = nil
                                        }
                                    }
                            )

                        // Show price popup if date is selected
                        if let selectedDate = selectedDate,
                           let dataPoint = chartData.first(where: { $0.date == selectedDate }) {

                            let dateX = proxy.position(forX: selectedDate) ?? 0

                            PricePopupView(dataPoint: dataPoint)
                                .position(x: dateX, y: geometry.size.height / 4)
                        }
                    }
                }
                .chartLegend(position: .bottom, spacing: 8) {
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
                .frame(maxHeight: .infinity)
                .padding(.horizontal)
                .padding(.bottom, 8)
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
            guard let buyPrice = Double(buyPriceString),
                  let sellPrice = Double(sellPriceString),
                  buyPrice > 0,  // Filter out 0 values
                  sellPrice > 0  // Filter out 0 values
            else {
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
        return chartData
    }

    private func calculatePriceRange(from chartData: [ChartDataPoint]) -> (Double, Double) {
        guard !chartData.isEmpty else { return (0, 100) }

        var allPrices: [Double] = []
        for dataPoint in chartData {
            allPrices.append(dataPoint.buyPrice)
            allPrices.append(dataPoint.sellPrice)
        }

        guard let minValue = allPrices.min(),
              let maxValue = allPrices.max() else {
            return (0, 100)
        }

        // Add padding to make the chart more readable (5% on each side)
        let range = maxValue - minValue
        let padding = range * 0.05
        let minPrice = max(0, minValue - padding)
        let maxPrice = maxValue + padding

        return (minPrice, maxPrice)
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

// MARK: - Price Popup View

struct PricePopupView: View {
    let dataPoint: ChartDataPoint

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Date header
            Text(dataPoint.dateUpdate)
                .font(.caption2)
                .foregroundColor(.secondary)

            // Buy price
            HStack(spacing: 6) {
                Circle()
                    .fill(.green)
                    .frame(width: 6, height: 6)

                Text("Mua:")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(formatFullPrice(dataPoint.buyPrice))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }

            // Sell price
            HStack(spacing: 6) {
                Circle()
                    .fill(.red)
                    .frame(width: 6, height: 6)

                Text("Bán:")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(formatFullPrice(dataPoint.sellPrice))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.separator), lineWidth: 1)
        )
    }

    private func formatFullPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = ","

        return formatter.string(from: NSNumber(value: price)) ?? "\(Int(price))"
    }
}

#Preview {
    DashboardGoldView()
}
