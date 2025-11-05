//
//  GoldDetailView.swift
//  GiaVangVN
//
//  Created by ORL on 30/10/25.
//

import SwiftUI

struct GoldDetailView: View {
    var goldProductName: String
    var branch: GoldBranch
    var city: String

    @StateObject private var viewModel: GoldDetailViewModel = GoldDetailViewModel()


    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ActivityIndicatorView()
            } else {
                buildResult()
            }
        }
        .navigationTitle(goldProductName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.getGoldDetail(product: goldProductName, branch: branch, city: city)
        }
        .task {
            AdsManager.shared().showInterstitialAd()
        }
    }

    @ViewBuilder
    func buildResult() -> some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        if let logoName = branch.rawValue as String? {
                            Image(logoName)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 32)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(goldProductName)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)

                            Text("\(branch.title) - \(city)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)

                // Range Selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(ListRange.allCases, id: \.self) { item in
                            Button {
                                withAnimation {
                                    viewModel.range = item
                                    viewModel.getGoldDetail(product: goldProductName, branch: branch, city: city)
                                }
                            } label: {
                                Text(item.title)
                                    .font(.subheadline)
                                    .fontWeight(viewModel.range == item ? .semibold : .regular)
                                    .foregroundColor(viewModel.range == item ? .white : .primary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        viewModel.range == item ?
                                        Color.accentColor :
                                        Color(.systemGray5)
                                    )
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Chart
                if let data = viewModel.goldData {
                    VStack(spacing: 0) {
                        GoldChartView(data: data)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                            .padding(.horizontal)

                        // Historical Data List
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Lịch sử giá")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding(.horizontal)
                                .padding(.top, 8)

                            buildHistoricalList(data: data)
                        }
                    }
                } else {
                    buildEmptyState()
                }
            }
            .padding(.vertical)
        }
    }

    @ViewBuilder
    func buildHistoricalList(data: GoldListData) -> some View {
        VStack(spacing: 0) {
            // Table Header
            HStack {
                Text("Ngày")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("Mua vào")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                Text("Bán ra")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.tertiarySystemBackground))

            Divider()

            // Data Rows
            ForEach(Array(data.list.enumerated()), id: \.element.id) { index, item in
                GoldListItemRow(item: item)

                if index != data.list.count - 1 {
                    Divider()
                        .padding(.leading, 16)
                }
            }
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    @ViewBuilder
    func buildEmptyState() -> some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("Không có dữ liệu")
                .font(.headline)
                .foregroundColor(.primary)

            Text("Vui lòng thử lại sau")
                .font(.caption)
                .foregroundColor(.secondary)

            Button {
                viewModel.getGoldDetail(product: goldProductName, branch: branch, city: city)
            } label: {
                Label("Làm mới", systemImage: "arrow.clockwise")
                    .font(.subheadline)
            }
            .buttonStyle(.bordered)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - Gold List Item Row

struct GoldListItemRow: View {
    let item: GoldListItem

    var body: some View {
        HStack {
            // Date
            Text(formatDate(item.dateUpdate))
                .font(.caption)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Buy Price
            VStack(alignment: .trailing, spacing: 4) {
                Text(ApiDecryptor.decrypt(item.buyDisplay))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                HStack(spacing: 2) {
                    Image(systemName: getDeltaIcon(for: ApiDecryptor.decrypt(item.buyDelta)))
                        .font(.caption2)
                        .foregroundColor(getDeltaColor(for: ApiDecryptor.decrypt(item.buyDelta)))

                    Text(formatDelta(ApiDecryptor.decrypt(item.buyDelta)))
                        .font(.caption2)
                        .foregroundColor(getDeltaColor(for: ApiDecryptor.decrypt(item.buyDelta)))
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)

            // Sell Price
            VStack(alignment: .trailing, spacing: 4) {
                Text(ApiDecryptor.decrypt(item.sellDisplay))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                HStack(spacing: 2) {
                    Image(systemName: getDeltaIcon(for: ApiDecryptor.decrypt(item.sellDelta)))
                        .font(.caption2)
                        .foregroundColor(getDeltaColor(for: ApiDecryptor.decrypt(item.sellDelta)))

                    Text(formatDelta(ApiDecryptor.decrypt(item.sellDelta)))
                        .font(.caption2)
                        .foregroundColor(getDeltaColor(for: ApiDecryptor.decrypt(item.sellDelta)))
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func formatDate(_ dateString: String) -> String {
        // Format date string (e.g., "2024-10-30" -> "30/10")
        let components = dateString.split(separator: "-")
        if components.count >= 3 {
            return "\(components[2])/\(components[1])"
        }
        return dateString
    }

    private func formatDelta(_ delta: String) -> String {
        return delta.replacingOccurrences(of: "+", with: "")
    }

    private func getDeltaIcon(for delta: String) -> String {
        if delta.hasPrefix("-") {
            return "arrow.down.right"
        } else if delta.hasPrefix("+") {
            return "arrow.up.right"
        } else {
            return "minus"
        }
    }

    private func getDeltaColor(for delta: String) -> Color {
        if delta.hasPrefix("-") {
            return .red
        } else if delta.hasPrefix("+") {
            return .green
        } else {
            return .secondary
        }
    }
}
