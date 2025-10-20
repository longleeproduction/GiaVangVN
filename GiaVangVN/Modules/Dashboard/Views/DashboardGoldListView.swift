//
//  DashboardGoldListView.swift
//  GiaVangVN
//
//  Created by L7 Mobile on 20/10/25.
//

import SwiftUI

struct DashboardGoldListView: View {
    @EnvironmentObject private var viewModel: DashBoardViewModel

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoadingListSJC {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                if let data = viewModel.listSJC {
                    buildListView(data: data)
                } else {
                    buildEmptyState()
                }
            }
        }
    }

    @ViewBuilder
    private func buildListView(data: GoldListData) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 4) {
                Text(data.title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(data.subTitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))

            Divider()

            // List
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(data.list) { item in
                        GoldPriceRow(item: item)

                        if item.id != data.list.last?.id {
                            Divider()
                                .padding(.leading, 16)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func buildEmptyState() -> some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("Không có dữ liệu")
                .font(.headline)
                .foregroundColor(.primary)

            Text("Vui lòng thử lại sau")
                .font(.caption)
                .foregroundColor(.secondary)

            Button {
                viewModel.getListPriceSJC()
            } label: {
                Label("Làm mới", systemImage: "arrow.clockwise")
                    .font(.subheadline)
            }
            .buttonStyle(.bordered)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Gold Price Row

struct GoldPriceRow: View {
    let item: GoldListItem

    var body: some View {
        let buyDelta: String =  ApiDecryptor.decrypt(item.buyDelta)
        let sellDelta: String = ApiDecryptor.decrypt(item.sellDelta)

        VStack(spacing: 12) {
            // Date Header
            HStack {
                Image(systemName: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(item.dateUpdate)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()
            }

            // Buy/Sell Prices
            HStack(spacing: 16) {
                // Buy Price
                VStack(alignment: .leading, spacing: 6) {
                    Text("Mua vào")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(ApiDecryptor.decrypt(item.buyDisplay))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)

                    HStack(spacing: 4) {
                        Image(systemName: getPriceIcon(for: buyDelta))
                            .font(.caption2)
                            .foregroundColor(getPriceColor(for: buyDelta))

                        Text(formatDelta(buyDelta))
                            .font(.caption2)
                            .foregroundColor(getPriceColor(for: buyDelta))

                        Text(ApiDecryptor.decrypt(item.buyPercent))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)

                // Sell Price
                VStack(alignment: .leading, spacing: 6) {
                    Text("Bán ra")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(ApiDecryptor.decrypt(item.sellDisplay))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)

                    HStack(spacing: 4) {
                        Image(systemName: getPriceIcon(for: sellDelta))
                            .font(.caption2)
                            .foregroundColor(getPriceColor(for: sellDelta))

                        Text(formatDelta(sellDelta))
                            .font(.caption2)
                            .foregroundColor(getPriceColor(for: sellDelta))

                        Text(ApiDecryptor.decrypt(item.sellPercent))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(16)
    }

    // MARK: - Helper Methods

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
        // Remove leading + or - for display
        return delta.replacingOccurrences(of: "+", with: "")
    }
}

#Preview {
    DashboardGoldListView()
        .environmentObject(DashBoardViewModel())
}
