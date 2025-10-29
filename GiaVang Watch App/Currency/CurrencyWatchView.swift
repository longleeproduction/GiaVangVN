//
//  CurrencyWatchView.swift
//  GiaVang Watch App
//
//  Created by ORL on 20/10/25.
//

import SwiftUI

struct CurrencyWatchView: View {

    @StateObject private var viewModel = CurrencyViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // Header
                    VStack(spacing: 4) {
                        Image(systemName: "banknote.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.green)

                        Text("Tỷ Giá")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 8)

                    Divider()

                    // VCB Section
                    if let vcbData = viewModel.vcb {
                        buildCurrencySection(
                            title: "VCB",
                            data: vcbData,
                            color: .blue,
                            currencyType: .vcb
                        )
                    } else {
                        ProgressView()
                            .padding()
                    }

                    Divider()

                    // BIDV Section
                    if let bidvData = viewModel.bidv {
                        buildCurrencySection(
                            title: "BIDV",
                            data: bidvData,
                            color: .orange,
                            currencyType: .bidv
                        )
                    } else {
                        ProgressView()
                            .padding()
                    }
                }
                .padding(.bottom, 8)
            }
            .task {
                viewModel.refreshData()
            }
            .environmentObject(viewModel)
        }
    }

    @ViewBuilder
    private func buildCurrencySection(title: String, data: CurrencyDailyData, color: Color, currencyType: CurrencyType) -> some View {
        VStack(spacing: 8) {
            // Section Header
            HStack {
                Text(title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(color)

                Spacer()

                Text(data.lastUpdate)
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)

            // Currency Items
            ForEach(data.list) { item in
                NavigationLink {
                    CurrencyDetailWatchView(item: item, currencyType: currencyType)
                } label: {
                    CurrencyRateCard(
                        code: item.code,
                        name: item.name,
                        buyRate: ApiDecryptor.decrypt(item.buyDisplay),
                        transferRate: ApiDecryptor.decrypt(item.transferDisplay),
                        sellRate: ApiDecryptor.decrypt(item.sellDisplay),
                        change: ApiDecryptor.decrypt(item.buyPercent),
                        color: color
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
    }
}

struct CurrencyRateCard: View {
    let code: String
    let name: String
    let buyRate: String
    let transferRate: String
    let sellRate: String
    let change: String
    var color: Color = .green

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
                Text(code)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                    .padding(4)
                    .background(Color.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                Spacer()

                Text(change)
                    .font(.caption2)
                    .foregroundColor(changeColor)
            }
            
            Text(name)
                .font(.system(size: 9))
                .foregroundColor(.secondary)
                .lineLimit(1)

            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Mua")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)

                    Text(buyRate)
                        .font(.system(size: 10))
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                    .frame(height: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text("CK")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)

                    Text(transferRate)
                        .font(.system(size: 10))
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Divider()
                    .frame(height: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Bán")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)

                    Text(sellRate)
                        .font(.system(size: 10))
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(8)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    CurrencyWatchView()
}
