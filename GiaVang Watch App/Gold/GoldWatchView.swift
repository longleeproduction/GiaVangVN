//
//  GoldWatchView.swift
//  GiaVang Watch App
//
//  Created by ORL on 20/10/25.
//

import SwiftUI

struct GoldWatchView: View {

    @StateObject private var viewModel = GoldWatchViewModel()

    var body: some View {
        NavigationStack {
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

                    // Branch Selector
                    VStack(spacing: 8) {
                        Text("Chi nhánh")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(GoldBranch.allCases, id: \.self) { branch in
                                    Button {
                                        viewModel.currentBranch = branch
                                        viewModel.getDailyGold(branch: branch)
                                    } label: {
                                        Text(branch.title)
                                            .font(.caption2)
                                            .fontWeight(viewModel.currentBranch == branch ? .bold : .regular)
                                            .foregroundColor(viewModel.currentBranch == branch ? .white : .primary)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(
                                                viewModel.currentBranch == branch
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

                    // Gold Data
                    if let goldData = viewModel.gold {
                        buildGoldSection(data: goldData)
                    } else {
                        ProgressView()
                            .padding()
                    }
                }
                .padding(.bottom, 8)
            }
            .onAppear {
                viewModel.getDailyGold(branch: viewModel.currentBranch)
            }
        }
    }

    @ViewBuilder
    private func buildGoldSection(data: GoldDailyData) -> some View {
        VStack(spacing: 8) {
            // Header with last update
            HStack {
                Text(viewModel.currentBranch.title)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)

                Spacer()

                Text(data.lastUpdate)
                    .font(.system(size: 8))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)

            // Cities and Gold Items
            ForEach(data.cities) { city in
                VStack(spacing: 6) {
                    // City Header
                    Text(city.city)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 8)

                    // Gold Items
                    ForEach(city.list) { item in
                        NavigationLink {
                            GoldDetailWatchView(gold: item, branch: viewModel.currentBranch, city: city.city)
                        } label: {
                            GoldPriceCard(item: item)
                        }.buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.horizontal, 8)
    }
}

struct GoldPriceCard: View {
    let item: GoldDailyItem

    var changeColor: Color {
        let change = ApiDecryptor.decrypt(item.buyPercent)
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
                Text(item.name)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: getDeltaIcon(ApiDecryptor.decrypt(item.buyDelta)))
                        .font(.system(size: 10))
                        .foregroundColor(changeColor)

                    Text(ApiDecryptor.decrypt(item.buyPercent))
                        .font(.system(size: 10))
                        .foregroundColor(changeColor)
                }
            }

            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Mua")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)

                    Text(ApiDecryptor.decrypt(item.buyDisplay))
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
                    Text("Bán")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)

                    Text(ApiDecryptor.decrypt(item.sellDisplay))
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
        .background(Color.yellow.opacity(0.1))
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
}

#Preview {
    GoldWatchView()
}
