//
//  GoldChartView.swift
//  GiaVangVN
//
//  Created by ORL on 20/10/25.
//

import SwiftUI
import Charts
import UIKit

struct GoldChartView: View {

    var data: GoldListData
    @State private var selectedDate: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text(data.title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(data.subTitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }.padding(.bottom, 8)

            // Chart
            let chartData = prepareChartData(from: data.list.reversed())

            if chartData.isEmpty {
                buildEmptyState()
            } else {
                let (minPrice, maxPrice) = calculatePriceRange(from: chartData)
                let chartWidth = calculateChartWidth(dataPointCount: chartData.count)
                let needsScrolling = chartData.count > 50 // Threshold for scrolling

                if needsScrolling {
                    // Scrollable chart for large datasets with fixed Y-axis
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            // Fixed Y-axis on the left
                            buildYAxisOnly(
                                chartData: chartData,
                                minPrice: minPrice,
                                maxPrice: maxPrice
                            )
                            .frame(width: 50)

                            // Scrollable chart content without Y-axis
                            ScrollView(.horizontal, showsIndicators: true) {
                                buildChart(
                                    chartData: chartData,
                                    minPrice: minPrice,
                                    maxPrice: maxPrice,
                                    width: chartWidth,
                                    showYAxis: false
                                )
                                .frame(width: chartWidth)
                            }
                            .scrollIndicators(.visible)
                        }
                    }
                    .frame(height: 280)
                    .padding(.bottom, 8)
                } else {
                    // Full-width chart for small datasets
                    buildChart(
                        chartData: chartData,
                        minPrice: minPrice,
                        maxPrice: maxPrice,
                        width: 0, // Will use maxWidth infinity
                        showYAxis: true
                    )
                    .frame(height: 280)
                    .padding(.bottom, 8)
                }

                // Legend - outside scroll view, always visible
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
                .frame(maxWidth: .infinity)
            }
        }
    }

    @ViewBuilder
    private func buildChart(chartData: [GoldChartDataPoint], minPrice: Double, maxPrice: Double, width: CGFloat, showYAxis: Bool = true) -> some View {
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
                        .frame(width: 4, height: 4)
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
                        .frame(width: 4, height: 4)
                }
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.catmullRom)
            }
        }
        .chartXAxis {
            let stride = calculateXAxisStride(dataPointCount: chartData.count)
            AxisMarks(preset: .aligned) { value in
                if let dateString = value.as(String.self),
                   let index = chartData.firstIndex(where: { $0.date == dateString }),
                   index % stride == 0 {
                    AxisValueLabel {
                        VStack(spacing: 2) {
                            // Day
                            Text(extractDay(from: dateString))
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.primary)

                            // Month
                            Text(extractMonth(from: dateString))
                                .font(.system(size: 8))
                                .foregroundColor(.secondary)
                        }
                    }
                    AxisTick()
                    AxisGridLine()
                }
            }
        }
        .chartYAxis {
            if showYAxis {
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
        }
        .chartYScale(domain: minPrice...maxPrice)
        .chartOverlay { proxy in
            // Overlay interactions commented out for better scrolling experience
            // Can be re-enabled if needed
        }
        .animation(.easeInOut(duration: 0.5), value: chartData.count)
        .transition(.opacity)
        .frame(maxWidth: width > 0 ? nil : .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func buildYAxisOnly(chartData: [GoldChartDataPoint], minPrice: Double, maxPrice: Double) -> some View {
        // Create a minimal chart just to display the Y-axis
        Chart {
            // Add a single invisible data point to establish the scale
            if let firstPoint = chartData.first {
                LineMark(
                    x: .value("", ""),
                    y: .value("", firstPoint.buyPrice)
                )
                .foregroundStyle(.clear)
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                if let price = value.as(Double.self), price > 0 {
                    AxisValueLabel {
                        Text(formatPrice(price))
                            .font(.caption2)
                    }
                }
            }
        }
        .chartYScale(domain: minPrice...maxPrice)
        .frame(height: 300)
    }

    @ViewBuilder
    private func buildEmptyState() -> some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("Không có dữ liệu biểu đồ")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(height: 300)
    }

    // MARK: - Helper Methods

    private func calculateChartWidth(dataPointCount: Int) -> CGFloat {
        // Only called for large datasets that need scrolling
        // Allocate comfortable space per data point for readable charts
        let pixelsPerPoint: CGFloat = 20 // Pixels per data point for scrollable charts
        let calculatedWidth = CGFloat(dataPointCount) * pixelsPerPoint

        // Ensure minimum width is at least screen width
        let minWidth: CGFloat = UIScreen.main.bounds.width
        return max(minWidth, calculatedWidth)
    }

    private func calculateXAxisStride(dataPointCount: Int) -> Int {
        // Calculate appropriate stride for X-axis labels based on data count
        switch dataPointCount {
        case 0...10:
            return 1 // Show every label
        case 11...30:
            return max(1, dataPointCount / 15) // ~15 labels
        case 31...90:
            return max(1, dataPointCount / 30) // ~30 labels
        case 91...180:
            return max(1, dataPointCount / 90) // ~90 labels
        default:
            return max(1, dataPointCount / 180) // ~180 labels for 365 days
        }
    }

    private func prepareChartData(from items: [GoldListItem]) -> [GoldChartDataPoint] {
        var chartData: [GoldChartDataPoint] = []

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

            let dataPoint = GoldChartDataPoint(
                id: item.id,
                date: displayDate,
                buyPrice: buyPrice,
                sellPrice: sellPrice,
                dateUpdate: item.dateUpdate
            )

            chartData.append(dataPoint)
        }

        // Already reversed, so this is oldest to newest
        return chartData
    }

    private func calculatePriceRange(from chartData: [GoldChartDataPoint]) -> (Double, Double) {
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

        // Add padding to make lines occupy ~2/3 of chart height (25% padding on each side)
        let range = maxValue - minValue
        let padding = range * 0.25
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

    private func extractDay(from dateString: String) -> String {
        // Input: "16/10" -> Output: "16"
        let components = dateString.split(separator: "/")
        if components.count >= 1 {
            return String(components[0])
        }
        return dateString
    }

    private func extractMonth(from dateString: String) -> String {
        // Input: "16/10" -> Output: "Th10" (Tháng 10)
        let components = dateString.split(separator: "/")
        if components.count >= 2 {
            let monthNum = String(components[1])
            return "T\(monthNum)"
        }
        return ""
    }
}

// MARK: - Gold Chart Data Model

struct GoldChartDataPoint: Identifiable {
    let id: String
    let date: String
    let buyPrice: Double
    let sellPrice: Double
    let dateUpdate: String
}

// MARK: - Gold Price Popup View

struct GoldPricePopupView: View {
    let dataPoint: GoldChartDataPoint

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
