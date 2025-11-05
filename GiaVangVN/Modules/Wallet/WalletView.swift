//
//  WalletView.swift
//  GiaVangVN
//
//  Created by ORL on 23/10/25.
//

import SwiftUI

struct WalletView: View {
    @StateObject private var viewModel = WalletViewModel()
    @State private var showAddBuyTransaction = false
    @State private var selectedTab: Tab = .holdings

    enum Tab {
        case holdings, sold
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Portfolio Summary Card
                portfolioSummaryCard

                // Tab Picker
                Picker("Loại", selection: $selectedTab) {
                    Text("Đang nắm giữ").tag(Tab.holdings)
                    Text("Đã bán").tag(Tab.sold)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)

                // Content
                if selectedTab == .holdings {
                    holdingsView
                } else {
                    soldView
                }
            }
            .navigationTitle("Danh mục vàng")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddBuyTransaction = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddBuyTransaction) {
                viewModel.refresh()
            } content: {
                AddBuyTransactionView()
            }
            .refreshable {
                viewModel.refresh()
            }
            .task {
                AdsManager.shared().showInterstitialAd()
            }
        }
    }

    // MARK: - Portfolio Summary Card
    private var portfolioSummaryCard: some View {
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad

        return VStack(spacing: isIPad ? 24 : 16) {
            // Total Profit/Loss
            VStack(spacing: isIPad ? 8 : 4) {
                Text("Tổng Lãi/Lỗ")
                    .font(isIPad ? .body : .caption)
                    .foregroundColor(.secondary)

                HStack(alignment: .firstTextBaseline, spacing: isIPad ? 8 : 4) {
                    Text(formatCurrency(viewModel.totalProfitLoss))
                        .font(.system(size: isIPad ? 48 : 32, weight: .bold))
                        .foregroundColor(viewModel.totalProfitLoss >= 0 ? .green : .red)

                    if viewModel.totalInvestment > 0 {
                        let percent = (viewModel.totalProfitLoss / viewModel.totalInvestment) * 100
                        Text(String(format: "(%.2f%%)", percent))
                            .font(isIPad ? .title2 : .headline)
                            .foregroundColor(viewModel.totalProfitLoss >= 0 ? .green : .red)
                    }
                }
            }

            // Details Grid
            HStack(spacing: isIPad ? 30 : 20) {
                VStack(spacing: isIPad ? 8 : 4) {
                    Text("Tổng đầu tư")
                        .font(isIPad ? .body : .caption)
                        .foregroundColor(.secondary)
                    Text(formatCurrencyShort(viewModel.totalInvestment))
                        .font(isIPad ? .title3 : .subheadline)
                        .fontWeight(.semibold)
                }

                Divider()
                    .frame(height: isIPad ? 45 : 30)

                VStack(spacing: isIPad ? 8 : 4) {
                    Text("Đã thực hiện")
                        .font(isIPad ? .body : .caption)
                        .foregroundColor(.secondary)
                    Text(formatCurrencyShort(viewModel.realizedProfitLoss))
                        .font(isIPad ? .title3 : .subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(viewModel.realizedProfitLoss >= 0 ? .green : .red)
                }

                Divider()
                    .frame(height: isIPad ? 45 : 30)

                VStack(spacing: isIPad ? 8 : 4) {
                    Text("Chưa thực hiện")
                        .font(isIPad ? .body : .caption)
                        .foregroundColor(.secondary)
                    Text(formatCurrencyShort(viewModel.unrealizedProfitLoss))
                        .font(isIPad ? .title3 : .subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(viewModel.unrealizedProfitLoss >= 0 ? .green : .red)
                }
            }
        }
        .padding(isIPad ? 24 : 16)
        .background(Color(.systemGray6))
        .cornerRadius(isIPad ? 24 : 16)
        .padding(isIPad ? 24 : 16)
    }

    // MARK: - Holdings View
    @ViewBuilder
    private var holdingsView: some View {
        let availableTransactions = viewModel.walletManager.getAvailableBuyTransactions()

        if availableTransactions.isEmpty {
            emptyHoldingsView
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(availableTransactions) { transaction in
                        BuyTransactionCard(
                            transaction: transaction,
                            currentPrice: viewModel.currentPrices[transaction.goldProduct]?.buy,
                            currentMarketPrices: viewModel.currentPrices[transaction.goldProduct],
                            onDelete: {
                                viewModel.deleteBuyTransaction(transaction)
                            }
                        )
                    }
                }
                .padding()
            }
        }
    }

    // MARK: - Sold View
    @ViewBuilder
    private var soldView: some View {
        let soldTransactions = viewModel.walletManager.sellTransactions

        if soldTransactions.isEmpty {
            emptySoldView
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(soldTransactions) { transaction in
                        SellTransactionCard(
                            transaction: transaction,
                            buyTransaction: viewModel.walletManager.buyTransactions.first(where: { $0.id == transaction.relatedBuyTransactionId }),
                            onDelete: {
                                viewModel.deleteSellTransaction(transaction)
                            }
                        )
                    }
                }
                .padding()
            }
        }
    }

    // MARK: - Empty States
    private var emptyHoldingsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis.circle")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            Text("Chưa có giao dịch mua")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("Nhấn nút + để thêm giao dịch mua vàng")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showAddBuyTransaction = true
            } label: {
                Label("Thêm giao dịch", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private var emptySoldView: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.up.right.circle")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            Text("Chưa có giao dịch bán")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("Các giao dịch bán sẽ hiển thị tại đây")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    // MARK: - Helper Functions
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = ","
        return (formatter.string(from: NSNumber(value: value)) ?? "0") + " VNĐ"
    }

    private func formatCurrencyShort(_ value: Double) -> String {
        if value >= 1_000_000_000 {
            return String(format: "%.1f tỷ", value / 1_000_000_000)
        } else if value >= 1_000_000 {
            return String(format: "%.0f tr", value / 1_000_000)
        } else {
            return formatCurrency(value)
        }
    }
}

// MARK: - Buy Transaction Card
struct BuyTransactionCard: View {
    let transaction: GoldTransactionModel
    let currentPrice: Double?  // Current buy price (what we can sell for)
    let currentMarketPrices: GoldPrice?  // Full market prices
    let onDelete: () -> Void

    @State private var showSellSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(transaction.goldProduct.rawValue)
                        .font(.headline)

                    HStack(spacing: 4) {
                        Text(transaction.goldProduct.city)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(transaction.goldProduct.branch.uppercased())
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }

                Spacer()

                // Sell Button
                Button {
                    showSellSheet = true
                } label: {
                    Label("Bán", systemImage: "arrow.up.right.circle.fill")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }

            Divider()

            // Transaction Details
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Số lượng")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(formatNumber(transaction.remainingQuantity)) chỉ")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Giá mua")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatCurrency(transaction.unitPrice))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }

            // Current Value & P/L
            if let currentPrice = currentPrice, let marketPrices = currentMarketPrices {
                let currentValue = transaction.remainingQuantity * currentPrice
                let costBasis = transaction.remainingQuantity * transaction.unitPrice
                let profitLoss = currentValue - costBasis

                VStack(spacing: 12) {
                    // Market Prices
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Giá mua vào")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(formatCurrency(marketPrices.sell))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Giá bán ra")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(formatCurrency(marketPrices.buy))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    }

                    Divider()

                    // Current P/L
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Giá trị hiện tại")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(formatCurrency(currentValue))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Lãi/Lỗ")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            HStack(spacing: 4) {
                                Image(systemName: profitLoss >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                    .font(.caption)
                                Text(formatCurrency(abs(profitLoss)))
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(profitLoss >= 0 ? .green : .red)
                        }
                    }

                    // Profit/Loss Percentage
                    if costBasis > 0 {
                        let profitPercent = (profitLoss / costBasis) * 100
                        HStack {
                            Spacer()
                            Text(String(format: "%.2f%%", profitPercent))
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(profitLoss >= 0 ? .green : .red)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    (profitLoss >= 0 ? Color.green : Color.red).opacity(0.15)
                                )
                                .cornerRadius(6)
                        }
                    }
                }
            }

            // Date
            HStack {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(formatDate(transaction.transactionDate))
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                if transaction.quantitySold > 0 {
                    Text("Đã bán: \(formatNumber(transaction.quantitySold)) chỉ")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Xóa", systemImage: "trash")
            }
        }
        .sheet(isPresented: $showSellSheet) {
            AddSellTransactionView(buyTransaction: transaction)
        }
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = ","
        return (formatter.string(from: NSNumber(value: value)) ?? "0") + " VNĐ"
    }

    private func formatNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Sell Transaction Card
struct SellTransactionCard: View {
    let transaction: GoldTransactionModel
    let buyTransaction: GoldTransactionModel?
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(transaction.goldProduct.rawValue)
                        .font(.headline)

                    HStack(spacing: 4) {
                        Text(transaction.goldProduct.city)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(transaction.goldProduct.branch.uppercased())
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }

                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }

            Divider()

            // Transaction Details
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Số lượng")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(formatNumber(transaction.quantity)) chỉ")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Giá bán")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatCurrency(transaction.unitPrice))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }

            // Profit/Loss
            if let buyTx = buyTransaction {
                let profitLoss = (transaction.quantity * transaction.unitPrice) - (transaction.quantity * buyTx.unitPrice)

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Vốn gốc")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formatCurrency(buyTx.unitPrice))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Lãi/Lỗ")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formatCurrency(profitLoss))
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(profitLoss >= 0 ? .green : .red)
                    }
                }
            }

            // Date
            HStack {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(formatDate(transaction.transactionDate))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Xóa", systemImage: "trash")
            }
        }
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.groupingSeparator = ","
        return (formatter.string(from: NSNumber(value: value)) ?? "0") + " VNĐ"
    }

    private func formatNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "0"
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    WalletView()
}
