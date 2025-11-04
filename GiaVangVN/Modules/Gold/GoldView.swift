//
//  GoldView.swift
//  GiaVangVN
//
//  Created by ORL on 15/10/25.
//

import SwiftUI

enum GoldViewMode: String, CaseIterable {
    case list = "Danh sách"
    case chart = "Biểu đồ"
}

struct GoldView: View {

    @StateObject private var viewModel = GoldViewModel()
    
    @State private var currentBranch: GoldBranch = GoldBranch.sjc
    @State private var isPresentedSetting: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Branch selector buttons
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(GoldBranch.allCases, id: \.self) { item in
                            Button {
                                withAnimation {
                                    currentBranch = item
                                }
                            } label: {
                                Text(item.title)
                                    .font(.subheadline)
                                    .fontWeight(currentBranch == item ? .semibold : .regular)
                                    .foregroundColor(currentBranch == item ? .white : .primary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        currentBranch == item ?
                                        Color.accentColor :
                                        Color(.systemGray5)
                                    )
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .background(Color(.systemBackground))

                Divider()

                // TabView with branch pages
                TabView(selection: $currentBranch) {
                    ForEach(GoldBranch.allCases, id: \.self) { branch in
                        GoldBranchPageView(branch: branch)
                            .tag(branch)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationBarTitleDisplayMode(.inline)
            .environmentObject(viewModel)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    AppHeaderView(title: "Giá Vàng")
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentedSetting.toggle()
                    } label: {
                        Image(systemName: "gear")
                    }
                }

            }
            .fullScreenCover(isPresented: $isPresentedSetting) {
                SettingView()
            }
        }
    }

    @ViewBuilder
    private func buildGoldList(data: GoldDailyData) -> some View {
        GoldListView(data: data)
    }

    @ViewBuilder
    private func buildEmptyState() -> some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("Không có dữ liệu giá vàng")
                .font(.headline)
                .foregroundColor(.primary)

            Text("Vui lòng thử lại sau")
                .font(.caption)
                .foregroundColor(.secondary)

            Button {
                viewModel.getDailyGold(branch: .sjc)
            } label: {
                Label("Làm mới", systemImage: "arrow.clockwise")
                    .font(.subheadline)
            }
            .buttonStyle(.bordered)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func buildChartEmptyState() -> some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("Không có dữ liệu biểu đồ")
                .font(.headline)
                .foregroundColor(.primary)

            Text("Vui lòng thử lại sau")
                .font(.caption)
                .foregroundColor(.secondary)

            Button {
                viewModel.getChartGold(branch: .sjc)
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

// MARK: - Gold List View

struct GoldListView: View {
    let data: GoldDailyData

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "circle.hexagongrid.fill")
                        .foregroundColor(.yellow)

                    Text("SJC - Giá vàng")
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
                VStack(spacing: 0) {
                    ForEach(data.cities) { city in
                        Section {
                            ForEach(city.list) { item in
                                GoldItemRow(item: item)

                                if item.id != city.list.last?.id {
                                    Divider()
                                        .padding(.leading, 16)
                                }
                            }
                        } header: {
                            HStack {
                                Text(city.city)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(.tertiarySystemBackground))
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Gold Item Row

struct GoldItemRow: View {
    let item: GoldDailyItem

    var body: some View {
        VStack(spacing: 12) {
            // Gold Product Name
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.headline)
                        .foregroundColor(.primary)
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
                .frame(width: 80, alignment: .leading)

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
    GoldView()
}
