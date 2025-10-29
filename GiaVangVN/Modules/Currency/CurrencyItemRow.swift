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
        HStack(spacing: 8) {
            // Currency Name and Code with Flag
            HStack(spacing: 8) {
                Text(getFlagEmoji(for: item.code))
                    .font(.system(size: 24))

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)

                    Text(item.code)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            // Buy Price
            buildPriceColumn(
                price: ApiDecryptor.decrypt(item.buyDisplay),
                delta: ApiDecryptor.decrypt(item.buyDelta)
            )

            Spacer()

            // Sell Price
            buildPriceColumn(
                price: ApiDecryptor.decrypt(item.sellDisplay),
                delta: ApiDecryptor.decrypt(item.sellDelta)
            )

            Spacer()

            // Transfer Price
            buildPriceColumn(
                price: ApiDecryptor.decrypt(item.transferDisplay),
                delta: ApiDecryptor.decrypt(item.transferDelta)
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    @ViewBuilder
    private func buildPriceColumn(price: String, delta: String) -> some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(price)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)

            HStack(spacing: 2) {
                Image(systemName: getPriceIcon(for: delta))
                    .font(.system(size: 9))
                    .foregroundColor(getPriceColor(for: delta))

                Text(formatDelta(delta))
                    .font(.system(size: 11))
                    .foregroundColor(getPriceColor(for: delta))
            }
        }
    }

    // MARK: - Helper Methods

    private func getFlagEmoji(for code: String) -> String {
        // Extract base currency code (handle USD(1-2-5) format)
        let baseCurrency: String
        if code.contains("(") {
            baseCurrency = String(code.split(separator: "(").first ?? "")
        } else {
            baseCurrency = code
        }

        // Map currency codes to country flags
        switch baseCurrency.uppercased() {
        case "USD": return "🇺🇸" // US Dollar
        case "EUR": return "🇪🇺" // Euro
        case "GBP": return "🇬🇧" // British Pound
        case "JPY": return "🇯🇵" // Japanese Yen
        case "CNY", "CHY": return "🇨🇳" // Chinese Yuan
        case "AUD": return "🇦🇺" // Australian Dollar
        case "CAD": return "🇨🇦" // Canadian Dollar
        case "CHF": return "🇨🇭" // Swiss Franc
        case "HKD": return "🇭🇰" // Hong Kong Dollar
        case "SGD": return "🇸🇬" // Singapore Dollar
        case "KRW": return "🇰🇷" // South Korean Won
        case "THB": return "🇹🇭" // Thai Baht
        case "MYR": return "🇲🇾" // Malaysian Ringgit
        case "NZD": return "🇳🇿" // New Zealand Dollar
        case "INR": return "🇮🇳" // Indian Rupee
        case "RUB": return "🇷🇺" // Russian Ruble
        case "DKK": return "🇩🇰" // Danish Krone
        case "NOK": return "🇳🇴" // Norwegian Krone
        case "SEK": return "🇸🇪" // Swedish Krona
        case "KWD": return "🇰🇼" // Kuwaiti Dinar
        case "SAR": return "🇸🇦" // Saudi Riyal
        case "AED": return "🇦🇪" // UAE Dirham
        case "LAK": return "🇱🇦" // Lao Kip
        case "KHR": return "🇰🇭" // Cambodian Riel
        case "IDR": return "🇮🇩" // Indonesian Rupiah
        case "PHP": return "🇵🇭" // Philippine Peso
        case "TWD": return "🇹🇼" // Taiwan Dollar
        default: return "💱" // Generic currency exchange symbol
        }
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
        // Remove leading + for display
        return delta.replacingOccurrences(of: "+", with: "")
    }
}
