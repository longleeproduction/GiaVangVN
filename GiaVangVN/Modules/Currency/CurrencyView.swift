//
//  CurrencyView.swift
//  GiaVangVN
//
//  Created by ORL on 15/10/25.
//

import SwiftUI

struct CurrencyView: View {

    @StateObject private var viewModel = CurrencyViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let vcbData = viewModel.vcb {
                    buildCurrencyList(data: vcbData)
                } else {
                    buildEmptyState()
                }
            }
            .navigationTitle(Text("Currency"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.getDailyCurrency(type: .vcb)
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .environmentObject(viewModel)
        }
    }

    @ViewBuilder
    private func buildCurrencyList(data: CurrencyDailyData) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "banknote")
                        .foregroundColor(.blue)

                    Text("VCB - Vietcombank")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Spacer()
                }

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("Cập nhật: \(data.lastUpdate)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text("Đơn vị: \(data.unit)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemBackground))

            Divider()

            // List
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(data.list) { item in
                        CurrencyItemRow(item: item)

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
            Image(systemName: "dollarsign.circle")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("Không có dữ liệu tỷ giá")
                .font(.headline)
                .foregroundColor(.primary)

            Text("Vui lòng thử lại sau")
                .font(.caption)
                .foregroundColor(.secondary)

            Button {
                viewModel.getDailyCurrency(type: .vcb)
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

// MARK: - Currency Item Row

struct CurrencyItemRow: View {
    let item: CurrencyDailyItem

    var body: some View {
        VStack(spacing: 12) {
            // Currency Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(item.code)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(4)
                }

                Spacer()
            }

            // Price Grid
            VStack(spacing: 8) {
                // Buy Price
                buildPriceRow(
                    title: "Mua vào",
                    price: ApiDecryptor.decrypt(item.buyDisplay),
                    delta: ApiDecryptor.decrypt(item.buyDelta),
                    percent: ApiDecryptor.decrypt(item.buyPercent),
                    color: .green
                )

                // Transfer Price
                buildPriceRow(
                    title: "Chuyển khoản",
                    price: ApiDecryptor.decrypt(item.transferDisplay),
                    delta: ApiDecryptor.decrypt(item.transferDelta),
                    percent: ApiDecryptor.decrypt(item.transferPercent),
                    color: .blue
                )

                // Sell Price
                buildPriceRow(
                    title: "Bán ra",
                    price: ApiDecryptor.decrypt(item.sellDisplay),
                    delta: ApiDecryptor.decrypt(item.sellDelta),
                    percent: ApiDecryptor.decrypt(item.sellPercent),
                    color: .red
                )
            }
        }
        .padding(16)
    }

    @ViewBuilder
    private func buildPriceRow(title: String, price: String, delta: String, percent: String, color: Color) -> some View {
        HStack(spacing: 12) {
            // Title
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 100, alignment: .leading)

            // Price
            Text(price)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Delta and Percent
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
            .frame(width: 90, alignment: .trailing)
        }
        .padding(10)
        .background(color.opacity(0.08))
        .cornerRadius(8)
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
        // Remove leading + for display
        return delta.replacingOccurrences(of: "+", with: "")
    }
}

#Preview {
    CurrencyView()
}
