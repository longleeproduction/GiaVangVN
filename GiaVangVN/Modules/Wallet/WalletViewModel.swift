//
//  WalletViewModel.swift
//  GiaVangVN
//
//  Created by ORL on 23/10/25.
//

import Foundation
import Combine

struct GoldPrice {
    let buy: Double  // Price when market buys from you (lower)
    let sell: Double // Price when market sells to you (higher)
}

@MainActor
class WalletViewModel: ObservableObject {
    @Published var walletManager = WalletManager.shared
    @Published var currentPrices: [GoldBuyerProduct: GoldPrice] = [:]
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

        // Calculate unrealized P/L using buy prices (what we can sell for)
        let priceDict = currentPrices.mapValues { $0.buy }
        unrealizedProfitLoss = walletManager.getUnrealizedProfitLoss(currentPrices: priceDict)
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
                // Decrypt and parse both buy and sell prices
                let buyString = ApiDecryptor.decrypt(data.buyDisplay).replacingOccurrences(of: ",", with: "")
                let sellString = ApiDecryptor.decrypt(data.sellDisplay).replacingOccurrences(of: ",", with: "")

                if let buyPrice = Double(buyString), let sellPrice = Double(sellString) {
                    currentPrices[product] = GoldPrice(buy: buyPrice, sell: sellPrice)
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
