//
//  CurrencyItemRow.swift
//  GiaVangVN
//
//  Created by ORL on 20/10/25.
//

import SwiftUI

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
