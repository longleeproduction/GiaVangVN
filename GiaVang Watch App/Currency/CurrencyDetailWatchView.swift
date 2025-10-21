//
//  CurrencyDetailWatchView.swift
//  GiaVangVN
//
//  Created by ORL on 21/10/25.
//

import SwiftUI
import Charts

struct CurrencyDetailWatchView: View {
    var item: CurrencyDailyItem
    var currencyType: CurrencyType

    @StateObject var viewModel = CurrencyDetailViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Current Rate Card
                VStack(spacing: 8) {
                    HStack {
                        Text(item.code)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(currencyType == .vcb ? .blue : .orange)

                        Spacer()
                    }

                    Text(item.name)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 8)

                Divider()


                // Historical Data
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                } else if let listData = viewModel.currencyList {
                    // Range Selector
                    VStack(spacing: 8) {
                        Text("Khoảng thời gian")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(ListRange.allCases, id: \.self) { range in
                                    Button {
                                        viewModel.range = range
                                        viewModel.getListCurrency(code: item.code, branch: currencyType.rawValue)
                                    } label: {
                                        Text(rangeLabel(range))
                                            .font(.caption2)
                                            .fontWeight(viewModel.range == range ? .bold : .regular)
                                            .foregroundColor(viewModel.range == range ? .white : .primary)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                viewModel.range == range
                                                ? (currencyType == .vcb ? Color.blue : Color.orange)
                                                : Color.gray.opacity(0.2)
                                            )
                                            .cornerRadius(12)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 8)

                    Divider()

                    buildHistoricalData(data: listData)
                } else {
                    Button {
                        viewModel.getListCurrency(code: item.code, branch: currencyType.rawValue)
                    } label: {
                        Label("Không có dữ liệu. Tải lại", systemImage: "arrow.circlepath")
                    }
                }
            }
            .padding(.bottom, 8)
        }
        .navigationTitle(item.code)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.getListCurrency(code: item.code, branch: currencyType.rawValue)
        }
    }

    @ViewBuilder
    private func buildHistoricalData(data: CurrencyListData) -> some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                Text("Lịch sử giá")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Spacer()

                Text("\(data.list.count) bản ghi")
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)

            // Mini Chart
            if !data.list.isEmpty {
                buildMiniChart(items: data.list)
            }

            Divider()

            // Historical List
            VStack(spacing: 6) {
                ForEach(data.list) { historyItem in
                    HistoricalRateRow(
                        item: historyItem,
                        color: currencyType == .vcb ? .blue : .orange
                    )
                }
            }
            .padding(.horizontal, 8)
        }
    }

    @ViewBuilder
    private func buildMiniChart(items: [CurrencyListItem]) -> some View {
        let chartData = items.reversed().compactMap { item -> (String, Double)? in
            guard let buyPrice = Double(ApiDecryptor.decrypt(item.buy)) else { return nil }
            return (formatDate(item.dateUpdate), buyPrice)
        }

        if !chartData.isEmpty {
            Chart {
                ForEach(Array(chartData.enumerated()), id: \.offset) { index, data in
                    LineMark(
                        x: .value("Date", index),
                        y: .value("Price", data.1)
                    )
                    .foregroundStyle(currencyType == .vcb ? .blue : .orange)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .interpolationMethod(.catmullRom)
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    if let price = value.as(Double.self) {
                        AxisValueLabel {
                            Text(formatPrice(price))
                                .font(.system(size: 8))
                        }
                        AxisGridLine()
                    }
                }
            }
            .frame(height: 80)
            .padding(.horizontal, 8)
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
}

struct HistoricalRateRow: View {
    let item: CurrencyListItem
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(formatDate(item.dateUpdate))
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: getDeltaIcon(ApiDecryptor.decrypt(item.buyDelta)))
                        .font(.system(size: 8))
                        .foregroundColor(getDeltaColor(ApiDecryptor.decrypt(item.buyDelta)))

                    Text(ApiDecryptor.decrypt(item.buyPercent))
                        .font(.system(size: 8))
                        .foregroundColor(getDeltaColor(ApiDecryptor.decrypt(item.buyDelta)))
                }
            }

            HStack(spacing: 4) {
                PriceCell(
                    label: "Mua",
                    value: ApiDecryptor.decrypt(item.buyDisplay),
                    valueColor: .green
                )

                PriceCell(
                    label: "CK",
                    value: ApiDecryptor.decrypt(item.transferDisplay),
                    valueColor: .blue
                )

                PriceCell(
                    label: "Bán",
                    value: ApiDecryptor.decrypt(item.sellDisplay),
                    valueColor: .red
                )
            }
        }
        .padding(6)
        .background(color.opacity(0.08))
        .cornerRadius(6)
    }

    private func formatDate(_ dateString: String) -> String {
        // Input: "09:01:00 16/10/2025"
        // Output: "16/10 09:01"
        let components = dateString.split(separator: " ")
        guard components.count >= 2 else { return dateString }

        let timeComponents = components[0].split(separator: ":")
        let dateComponents = components[1].split(separator: "/")

        if timeComponents.count >= 2 && dateComponents.count >= 2 {
            return "\(dateComponents[0])/\(dateComponents[1]) \(timeComponents[0]):\(timeComponents[1])"
        }

        return dateString
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

struct PriceCell: View {
    let label: String
    let value: String
    let valueColor: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 7))
                .foregroundColor(.secondary)

            Text(value)
                .font(.system(size: 9))
                .fontWeight(.medium)
                .foregroundColor(valueColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        CurrencyDetailWatchView(
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
