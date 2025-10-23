//
//  WalletViewModel.swift
//  GiaVangVN
//
//  Created by ORL on 23/10/25.
//

import Foundation
import Combine

@MainActor
class WalletViewModel: ObservableObject {
    @Published var walletManager = WalletManager.shared
    @Published var currentPrices: [GoldBuyerProduct: Double] = [:]
    @Published var isLoadingPrices: Bool = false

    @Published var totalInvestment: Double = 0
    @Published var totalSold: Double = 0
    @Published var realizedProfitLoss: Double = 0
    @Published var unrealizedProfitLoss: Double = 0
    @Published var totalProfitLoss: Double = 0

    init() {
        calculateTotals()
        fetchCurrentPrices()
    }

    func refresh() {
        calculateTotals()
        fetchCurrentPrices()
    }

    func calculateTotals() {
        totalInvestment = walletManager.getTotalInvestment()
        totalSold = walletManager.getTotalSoldAmount()
        realizedProfitLoss = walletManager.getTotalProfitLoss()
        unrealizedProfitLoss = walletManager.getUnrealizedProfitLoss(currentPrices: currentPrices)
        totalProfitLoss = realizedProfitLoss + unrealizedProfitLoss
    }

    func fetchCurrentPrices() {
        isLoadingPrices = true

        Task {
            // Fetch prices for all unique products in active buy transactions
            let activeProducts = Set(walletManager.getAvailableBuyTransactions().map { $0.goldProduct })

            for product in activeProducts {
                await fetchPrice(for: product)
            }

            isLoadingPrices = false
            calculateTotals()
        }
    }

    private func fetchPrice(for product: GoldBuyerProduct) async {
        do {
            let request = GoldPriceRequest(
                product: product.rawValue,
                city: product.city,
                lang: "vi",
                branch: product.branch
            )
            let response = try await DashboardService.shared.fetchGoldPrice(request: request)

            if let data = response.data {
                // Parse sellDisplay to get numeric value
                // Remove commas and convert to Double
                let priceString = data.sellDisplay.replacingOccurrences(of: ",", with: "")
                if let sellPrice = Double(priceString) {
                    currentPrices[product] = sellPrice
                }
            }
        } catch {
            print("Error fetching price for \(product.rawValue): \(error)")
        }
    }

    func deleteBuyTransaction(_ transaction: GoldTransactionModel) {
        walletManager.deleteTransaction(transaction)
        calculateTotals()
    }

    func deleteSellTransaction(_ transaction: GoldTransactionModel) {
        walletManager.deleteTransaction(transaction)
        calculateTotals()
    }
}
