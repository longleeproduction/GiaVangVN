//
//  GoldDetailWatchView.swift
//  GiaVangVN
//
//  Created by ORL on 21/10/25.
//

import SwiftUI
import Charts

struct GoldDetailWatchView: View {

    var goldProductName: String
    var branch: GoldBranch
    var city: String

    @StateObject private var viewModel: GoldDetailViewModel = GoldDetailViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Current Info Card
                VStack(spacing: 8) {
                    HStack {
                        Text(goldProductName)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)

                        Spacer()
                    }

                    Text("\(branch.title) - \(city)")
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
                } else if let listData = viewModel.goldData {
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
                                        viewModel.getGoldDetail(product: goldProductName, branch: branch, city: city)
                                    } label: {
                                        Text(rangeLabel(range))
                                            .font(.caption2)
                                            .fontWeight(viewModel.range == range ? .bold : .regular)
                                            .foregroundColor(viewModel.range == range ? .white : .primary)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                viewModel.range == range
                                                ? Color.orange
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
                        viewModel.getGoldDetail(product: goldProductName, branch: branch, city: city)
                    } label: {
                        Label("Không có dữ liệu. Tải lại", systemImage: "arrow.circlepath")
                    }
                }
            }
            .padding(.bottom, 8)
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.getGoldDetail(product: goldProductName, branch: branch, city: city)
        }
    }

    @ViewBuilder
    private func buildHistoricalData(data: GoldListData) -> some View {
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
                    HistoricalGoldRow(item: historyItem)
                }
            }
            .padding(.horizontal, 8)
        }
    }

    @ViewBuilder
    private func buildMiniChart(items: [GoldListItem]) -> some View {
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
                    .foregroundStyle(.orange)
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

struct HistoricalGoldRow: View {
    let item: GoldListItem

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
                GoldPriceCell(
                    label: "Mua",
                    value: ApiDecryptor.decrypt(item.buyDisplay),
                    valueColor: .green
                )

                GoldPriceCell(
                    label: "Bán",
                    value: ApiDecryptor.decrypt(item.sellDisplay),
                    valueColor: .red
                )
            }
        }
        .padding(6)
        .background(Color.orange.opacity(0.08))
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

struct GoldPriceCell: View {
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
