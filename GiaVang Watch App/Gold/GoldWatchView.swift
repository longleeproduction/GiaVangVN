//
//  GoldWatchView.swift
//  GiaVang Watch App
//
//  Created by ORL on 20/10/25.
//

import SwiftUI

struct GoldWatchView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Header
                VStack(spacing: 4) {
                    Image(systemName: "circle.hexagongrid.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.yellow)

                    Text("Giá Vàng")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                .padding(.top, 8)

                Divider()

                // Gold Prices
                VStack(spacing: 8) {
                    GoldPriceCard(
                        name: "Vàng SJC",
                        buyPrice: "94.50",
                        sellPrice: "95.00",
                        change: "+0.5%"
                    )

                    GoldPriceCard(
                        name: "Vàng 24K",
                        buyPrice: "85.20",
                        sellPrice: "85.80",
                        change: "+0.3%"
                    )

                    GoldPriceCard(
                        name: "Vàng 18K",
                        buyPrice: "63.90",
                        sellPrice: "64.40",
                        change: "-0.2%"
                    )
                }
                .padding(.horizontal, 8)
            }
            .padding(.bottom, 8)
        }
    }
}

struct GoldPriceCard: View {
    let name: String
    let buyPrice: String
    let sellPrice: String
    let change: String

    var changeColor: Color {
        if change.hasPrefix("+") {
            return .green
        } else if change.hasPrefix("-") {
            return .red
        } else {
            return .secondary
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(name)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Spacer()

                Text(change)
                    .font(.caption2)
                    .foregroundColor(changeColor)
            }

            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Mua")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)

                    Text(buyPrice)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Divider()
                    .frame(height: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Bán")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)

                    Text(sellPrice)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(8)
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    GoldWatchView()
}
