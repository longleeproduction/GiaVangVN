//
//  CurrencyDetailView.swift
//  GiaVangVN
//
//  Created by ORL on 29/10/25.
//

import SwiftUI
import Charts

struct CurrencyDetailView: View {
    let item: CurrencyDailyItem
    let currencyType: CurrencyType

    @StateObject var viewModel = CurrencyDetailViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Current Rate Card
                VStack(spacing: 12) {
                    HStack {
                        Text(getCurrencyFlag(for: item.code))
                            .font(.system(size: 40))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.code)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(currencyType == .vcb ? .blue : .orange)

                            Text(item.name)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    // Current Rates Grid
                    HStack(spacing: 10) {
                        rateCard(
                            title: "Mua vào",
                            value: ApiDecryptor.decrypt(item.buyDisplay),
                            delta: ApiDecryptor.decrypt(item.buyDelta),
                            percent: ApiDecryptor.decrypt(item.buyPercent),
                            color: .green
                        )

                        rateCard(
                            title: "Bán ra",
                            value: ApiDecryptor.decrypt(item.sellDisplay),
                            delta: ApiDecryptor.decrypt(item.sellDelta),
                            percent: ApiDecryptor.decrypt(item.sellPercent),
                            color: .red
                        )

                        rateCard(
                            title: "Mua CK",
                            value: ApiDecryptor.decrypt(item.transferDisplay),
                            delta: ApiDecryptor.decrypt(item.transferDelta),
                            percent: ApiDecryptor.decrypt(item.transferPercent),
                            color: .blue
                        )
                    }
                }
                .padding(.horizontal, 10)
                .padding(.top)

                // Historical Data Section
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                } else if let listData = viewModel.currencyList {
                    VStack(spacing: 16) {
                        // Range Selector
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Khoảng thời gian")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(ListRange.allCases, id: \.self) { range in
                                        Button {
                                            viewModel.range = range
                                            viewModel.getListCurrency(code: item.code, branch: currencyType.rawValue)
                                        } label: {
                                            Text(rangeLabel(range))
                                                .font(.subheadline)
                                                .fontWeight(viewModel.range == range ? .bold : .regular)
                                                .foregroundColor(viewModel.range == range ? .white : .primary)
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 10)
                                                .background(
                                                    viewModel.range == range
                                                    ? (currencyType == .vcb ? Color.blue : Color.orange)
                                                    : Color(.secondarySystemBackground)
                                                )
                                                .cornerRadius(20)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

                        Divider()
                            .padding(.horizontal)

                        buildHistoricalData(data: listData)
                    }
                } else {
                    Button {
                        viewModel.getListCurrency(code: item.code, branch: currencyType.rawValue)
                    } label: {
                        Label("Không có dữ liệu. Tải lại", systemImage: "arrow.circlepath")
                            .font(.headline)
                            .padding()
                    }
                }
            }
            .padding(.bottom)
        }
        .navigationTitle(item.code)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.getListCurrency(code: item.code, branch: currencyType.rawValue)
            
            AdsManager.shared().showInterstitialAd()
        }
    }

    @ViewBuilder
    private func rateCard(title: String, value: String, delta: String, percent: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            HStack(spacing: 4) {
                Image(systemName: getPriceIcon(for: delta))
                    .font(.caption2)
                    .foregroundColor(getPriceColor(for: delta))

                Text(formatDelta(delta))
                    .font(.caption2)
                    .foregroundColor(getPriceColor(for: delta))

                Text(percent)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 6)
        .padding(.bottom, 12)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }

    @ViewBuilder
    private func buildHistoricalData(data: CurrencyListData) -> some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Lịch sử giá")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                Text("\(data.list.count) bản ghi")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)

            // Chart
            if !data.list.isEmpty {
                buildChart(items: data.list)
            }

            Divider()
                .padding(.horizontal)

            // Historical List
            VStack(spacing: 12) {
                ForEach(data.list) { historyItem in
                    HistoricalRateRowiPhone(
                        item: historyItem,
                        color: currencyType == .vcb ? .blue : .orange
                    )
                }
            }
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private func buildChart(items: [CurrencyListItem]) -> some View {
        let chartData = items.reversed().compactMap { item -> (String, Double)? in
            guard let buyPrice = Double(ApiDecryptor.decrypt(item.buy)) else { return nil }
            return (formatDate(item.dateUpdate), buyPrice)
        }

        if !chartData.isEmpty {
            // Calculate min and max values for better Y-axis scaling
            let prices = chartData.map { $0.1 }
            let minPrice = prices.min() ?? 0
            let maxPrice = prices.max() ?? 0

            // Calculate range and add padding (10% on each side)
            let range = maxPrice - minPrice
            let padding = max(range * 0.15, 1.0) // At least 1 unit of padding
            let yMin = minPrice - padding
            let yMax = maxPrice + padding

            Chart {
                ForEach(Array(chartData.enumerated()), id: \.offset) { index, data in
                    LineMark(
                        x: .value("Date", index),
                        y: .value("Price", data.1)
                    )
                    .foregroundStyle(currencyType == .vcb ? .blue : .orange)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    .interpolationMethod(.catmullRom)
                    .symbol {
                        Circle()
                            .fill(currencyType == .vcb ? Color.blue : Color.orange)
                            .frame(width: 6, height: 6)
                    }
                    .symbolSize(30)

                    AreaMark(
                        x: .value("Date", index),
                        y: .value("Price", data.1)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                (currencyType == .vcb ? Color.blue : Color.orange).opacity(0.3),
                                (currencyType == .vcb ? Color.blue : Color.orange).opacity(0.05)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                }
            }
            .chartXAxis(.hidden)
            .chartYScale(domain: yMin...yMax)
            .chartYAxis {
                AxisMarks(position: .leading, values: .stride(by: range / 4)) { value in
                    if let price = value.as(Double.self) {
                        AxisValueLabel {
                            Text(formatChartPrice(price))
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                            .foregroundStyle(Color.gray.opacity(0.3))
                    }
                }
            }
            .frame(height: 220)
            .padding(.horizontal)
            .clipped()
        }
    }

    private func getCurrencyFlag(for code: String) -> String {
        // Extract base currency code (handle USD(1-2-5) format)
        let baseCurrency: String
        if code.contains("(") {
            baseCurrency = String(code.split(separator: "(").first ?? "")
        } else {
            baseCurrency = code
        }

        // Map currency codes to country flags
        switch baseCurrency.uppercased() {
        case "USD": return "🇺🇸"
        case "EUR": return "🇪🇺"
        case "GBP": return "🇬🇧"
        case "JPY": return "🇯🇵"
        case "CNY", "CHY": return "🇨🇳"
        case "AUD": return "🇦🇺"
        case "CAD": return "🇨🇦"
        case "CHF": return "🇨🇭"
        case "HKD": return "🇭🇰"
        case "SGD": return "🇸🇬"
        case "KRW": return "🇰🇷"
        case "THB": return "🇹🇭"
        case "MYR": return "🇲🇾"
        case "NZD": return "🇳🇿"
        case "INR": return "🇮🇳"
        case "RUB": return "🇷🇺"
        case "DKK": return "🇩🇰"
        case "NOK": return "🇳🇴"
        case "SEK": return "🇸🇪"
        case "KWD": return "🇰🇼"
        case "SAR": return "🇸🇦"
        case "AED": return "🇦🇪"
        case "LAK": return "🇱🇦"
        case "KHR": return "🇰🇭"
        case "IDR": return "🇮🇩"
        case "PHP": return "🇵🇭"
        case "TWD": return "🇹🇼"
        default: return "💱"
        }
    }

    private func rangeLabel(_ range: ListRange) -> String {
        switch range {
        case .Range7d: return "7 ngày"
        case .Range30d: return "30 ngày"
        case .Range60d: return "60 ngày"
        case .Range180d: return "180 ngày"
        case .Range365d: return "1 năm"
        }
    }

    private func formatDate(_ dateString: String) -> String {
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

        if price >= 1_000 {
            let inThousands = price / 1_000
            return String(format: "%.0fK", inThousands)
        } else {
            return formatter.string(from: NSNumber(value: price)) ?? "\(Int(price))"
        }
    }

    private func formatChartPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: price)) ?? "\(Int(price))"
    }

    private func getPriceIcon(for delta: String) -> String {
        if delta.hasPrefix("-") {
            return "arrow.down.right"
        } else if delta.hasPrefix("+") {
            return "arrow.up.right"
        } else {
            return "minus"
        }
    }

    private func getPriceColor(for delta: String) -> Color {
        if delta.hasPrefix("-") {
            return .red
        } else if delta.hasPrefix("+") {
            return .green
        } else {
            return .secondary
        }
    }

    private func formatDelta(_ delta: String) -> String {
        return delta.replacingOccurrences(of: "+", with: "")
    }
}

struct HistoricalRateRowiPhone: View {
    let item: CurrencyListItem
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(formatDate(item.dateUpdate))
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: getDeltaIcon(ApiDecryptor.decrypt(item.buyDelta)))
                        .font(.caption)
                        .foregroundColor(getDeltaColor(ApiDecryptor.decrypt(item.buyDelta)))

                    Text(ApiDecryptor.decrypt(item.buyPercent))
                        .font(.caption)
                        .foregroundColor(getDeltaColor(ApiDecryptor.decrypt(item.buyDelta)))
                }
            }

            HStack(spacing: 12) {
                PriceCelliPhone(
                    label: "Mua vào",
                    value: ApiDecryptor.decrypt(item.buyDisplay),
                    valueColor: .green
                )

                PriceCelliPhone(
                    label: "Chuyển khoản",
                    value: ApiDecryptor.decrypt(item.transferDisplay),
                    valueColor: .blue
                )

                PriceCelliPhone(
                    label: "Bán ra",
                    value: ApiDecryptor.decrypt(item.sellDisplay),
                    valueColor: .red
                )
            }
        }
        .padding()
        .background(color.opacity(0.08))
        .cornerRadius(12)
    }

    private func formatDate(_ dateString: String) -> String {
        // Input: "09:01:00 16/10/2025"
        // Output: "16/10/2025 09:01"
        let components = dateString.split(separator: " ")
        guard components.count >= 2 else { return dateString }

        let timeComponents = components[0].split(separator: ":")
        let dateString = components[1]

        if timeComponents.count >= 2 {
            return "\(dateString) \(timeComponents[0]):\(timeComponents[1])"
        }

        return String(dateString)
    }

    private func getDeltaIcon(_ delta: String) -> String {
        if delta.hasPrefix("-") {
            return "arrow.down"
        } else if delta.hasPrefix("+") {
            return "arrow.up"
        } else {
            return "minus"
        }
    }

    private func getDeltaColor(_ delta: String) -> Color {
        if delta.hasPrefix("-") {
            return .red
        } else if delta.hasPrefix("+") {
            return .green
        } else {
            return .secondary
        }
    }
}

struct PriceCelliPhone: View {
    let label: String
    let value: String
    let valueColor: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        CurrencyDetailView(
            item: CurrencyDailyItem(
                name: "US Dollar",
                code: "USD",
                buy: "encrypted",
                buyDisplay: "25,450",
                buyLast: "25,400",
                buyLastDisplay: "25,400",
                buyDelta: "+50",
                buyPercent: "+0.2%",
                sell: "encrypted",
                sellDisplay: "25,500",
                sellLast: "25,450",
                sellLastDisplay: "25,450",
                sellDelta: "+50",
                sellPercent: "+0.2%",
                transfer: "encrypted",
                transferDisplay: "25,475",
                transferLast: "25,425",
                transferLastDisplay: "25,425",
                transferDelta: "+50",
                transferPercent: "+0.2%",
                dateUpdate: "10:30:00 21/10/2025",
                lastUpdate: "10:30:00 21/10/2025"
            ),
            currencyType: .vcb
        )
    }
}
