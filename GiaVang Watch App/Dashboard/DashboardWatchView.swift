//
//  DashboardWatchView.swift
//  GiaVang Watch App
//
//  Created by ORL on 20/10/25.
//

import SwiftUI

struct DashboardWatchView: View {

    @StateObject private var viewModel = DashBoardViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // Header
                    VStack(spacing: 4) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        
                        Text("Trang chủ")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 8)
                    
                    Divider()
                    
                    // Box Price Gold SJC
                    NavigationLink {
                        GoldDetailWatchView(goldProductName: "Vàng miếng SJC", branch: .sjc, city: "Hồ Chí Minh")
                    } label: {
                        GoldPriceBox(
                            title: "Vàng miếng SJC",
                            data: viewModel.priceSJC,
                            isLoading: viewModel.isLoadingPriceSJC,
                            color: .yellow
                        )
                    }.buttonStyle(.plain)
                    
                    // Box Price Gold 9999
                    NavigationLink {
                        GoldDetailWatchView(goldProductName: "Vàng nhẫn 9999", branch: .sjc, city: "Hồ Chí Minh")
                    } label: {
                        GoldPriceBox(
                            title: "Vàng nhẫn 9999",
                            data: viewModel.price9999,
                            isLoading: viewModel.isLoadingPrice9999,
                            color: .orange
                        )
                    }.buttonStyle(.plain)
                    
                    // Box price ag Phu Quy 999
                    NavigationLink {
                        GoldDetailWatchView(goldProductName: "Bạc thỏi Phú Quý 999", branch: .phuquy, city: "Hà Nội")
                    } label: {
                        GoldPriceBox(
                            title: "Bạc thỏi Phú Quý 999",
                            data: viewModel.priceAg999,
                            isLoading: viewModel.isLoadingPriceAg999,
                            color: .gray
                        )
                    }.buttonStyle(.plain)
                    
                    // Currency USD of VCB
                    NavigationLink {
                        CurrencyDetailWatchView(item: CurrencyDailyItem(name: "Tỷ giá USD", code: "USD", buy: "", buyDisplay: "", buyLast: "", buyLastDisplay: "", buyDelta: "", buyPercent: "", sell: "", sellDisplay: "", sellLast: "", sellLastDisplay: "", sellDelta: "", sellPercent: "", transfer: "", transferDisplay: "", transferLast: "", transferLastDisplay: "", transferDelta: "", transferPercent: "", dateUpdate: "", lastUpdate: ""), currencyType: .vcb)
                    } label: {
                        CurrencyPriceBox(
                            title: "Tỷ giá USD",
                            data: viewModel.currency,
                            isLoading: viewModel.isLoadingCurrency,
                            color: .green,
                            onRefresh: {
                                refreshAllData()
                            }
                        )
                    }.buttonStyle(.plain)
                    
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
        }
    }

    private func refreshAllData() {
        viewModel.getPriceSJC()
        viewModel.getPrice999()
        viewModel.getAg9999()
        viewModel.getCurrency()
    }
}

struct GoldPriceBox: View {
    let title: String
    let data: GoldPriceData?
    let isLoading: Bool
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                Image(systemName: "circle.hexagongrid.fill")
                    .font(.caption)
                    .foregroundColor(color)

                Text(title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Spacer()
            }

            if isLoading {
                ProgressView()
                    .padding(.vertical, 8)
            } else if let data = data {
                VStack(spacing: 6) {
                    // Prices
                    HStack(spacing: 4) {
                        // Buy Price
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Mua")
                                .font(.system(size: 8))
                                .foregroundColor(.secondary)

                            Text(ApiDecryptor.decrypt(data.buyDisplay))
                                .font(.system(size: 10))
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)

                            HStack(spacing: 2) {
                                Image(systemName: getDeltaIcon(ApiDecryptor.decrypt(data.buyDelta)))
                                    .font(.system(size: 7))
                                    .foregroundColor(getDeltaColor(ApiDecryptor.decrypt(data.buyDelta)))

                                Text(ApiDecryptor.decrypt(data.buyPercent))
                                    .font(.system(size: 7))
                                    .foregroundColor(getDeltaColor(ApiDecryptor.decrypt(data.buyDelta)))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Divider()
                            .frame(height: 30)

                        // Sell Price
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Bán")
                                .font(.system(size: 8))
                                .foregroundColor(.secondary)

                            Text(ApiDecryptor.decrypt(data.sellDisplay))
                                .font(.system(size: 10))
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)

                            HStack(spacing: 2) {
                                Image(systemName: getDeltaIcon(ApiDecryptor.decrypt(data.sellDelta)))
                                    .font(.system(size: 7))
                                    .foregroundColor(getDeltaColor(ApiDecryptor.decrypt(data.sellDelta)))

                                Text(ApiDecryptor.decrypt(data.sellPercent))
                                    .font(.system(size: 7))
                                    .foregroundColor(getDeltaColor(ApiDecryptor.decrypt(data.sellDelta)))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Update time
                    Text(data.dateUpdate)
                        .font(.system(size: 7))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            } else {
                Text("Không có dữ liệu")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            }
        }
        .padding(8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
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

struct CurrencyPriceBox: View {
    let title: String
    let data: CurrencyPriceData?
    let isLoading: Bool
    let color: Color
    let onRefresh: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.caption)
                    .foregroundColor(color)

                Text(title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Spacer()
            }

            if isLoading {
                ProgressView()
                    .padding(.vertical, 8)
            } else if let data = data {
                VStack(spacing: 6) {
                    // Currency code
                    Text(data.code)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Prices
                    VStack(spacing: 4) {
                        // Buy Price
                        HStack(spacing: 4) {
                            Text("Mua:")
                                .font(.system(size: 8))
                                .foregroundColor(.secondary)
                                .frame(width: 35, alignment: .leading)

                            Text(ApiDecryptor.decrypt(data.buyDisplay))
                                .font(.system(size: 10))
                                .fontWeight(.semibold)
                                .foregroundColor(.green)

                            Spacer()

                            HStack(spacing: 2) {
                                Image(systemName: getDeltaIcon(ApiDecryptor.decrypt(data.buyDelta)))
                                    .font(.system(size: 7))
                                    .foregroundColor(getDeltaColor(ApiDecryptor.decrypt(data.buyDelta)))

                                Text(ApiDecryptor.decrypt(data.buyPercent))
                                    .font(.system(size: 7))
                                    .foregroundColor(getDeltaColor(ApiDecryptor.decrypt(data.buyDelta)))
                            }
                        }

                        // Transfer Price
                        HStack(spacing: 4) {
                            Text("CK:")
                                .font(.system(size: 8))
                                .foregroundColor(.secondary)
                                .frame(width: 35, alignment: .leading)

                            Text(ApiDecryptor.decrypt(data.transferDisplay))
                                .font(.system(size: 10))
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)

                            Spacer()

                            HStack(spacing: 2) {
                                Image(systemName: getDeltaIcon(ApiDecryptor.decrypt(data.transferDelta)))
                                    .font(.system(size: 7))
                                    .foregroundColor(getDeltaColor(ApiDecryptor.decrypt(data.transferDelta)))

                                Text(ApiDecryptor.decrypt(data.transferPercent))
                                    .font(.system(size: 7))
                                    .foregroundColor(getDeltaColor(ApiDecryptor.decrypt(data.transferDelta)))
                            }
                        }

                        // Sell Price
                        HStack(spacing: 4) {
                            Text("Bán:")
                                .font(.system(size: 8))
                                .foregroundColor(.secondary)
                                .frame(width: 35, alignment: .leading)

                            Text(ApiDecryptor.decrypt(data.sellDisplay))
                                .font(.system(size: 10))
                                .fontWeight(.semibold)
                                .foregroundColor(.red)

                            Spacer()

                            HStack(spacing: 2) {
                                Image(systemName: getDeltaIcon(ApiDecryptor.decrypt(data.sellDelta)))
                                    .font(.system(size: 7))
                                    .foregroundColor(getDeltaColor(ApiDecryptor.decrypt(data.sellDelta)))

                                Text(ApiDecryptor.decrypt(data.sellPercent))
                                    .font(.system(size: 7))
                                    .foregroundColor(getDeltaColor(ApiDecryptor.decrypt(data.sellDelta)))
                            }
                        }
                    }

                    // Update time
                    Text(data.dateUpdate)
                        .font(.system(size: 7))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    Divider()

                    // Refresh Button
                    Button {
                        onRefresh()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 10))

                            Text("Làm mới")
                                .font(.system(size: 10))
                                .fontWeight(.medium)
                        }
                        .foregroundColor(color)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                Text("Không có dữ liệu")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            }
        }
        .padding(8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
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
