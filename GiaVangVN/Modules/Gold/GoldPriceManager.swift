//
//  GoldPriceManager.swift
//  GiaVangVN
//
//  Created by ORL on 04/11/25.
//

import Foundation
import Combine

/// Singleton class that manages all gold buyer product prices
/// Used by Wallet and Calculator features
@MainActor
class GoldPriceManager: ObservableObject {
    static let shared = GoldPriceManager()

    /// Dictionary of current prices for each GoldBuyerProduct
    @Published private(set) var prices: [GoldBuyerProduct: Double] = [:]

    /// Dictionary of sell price displays (formatted strings) for each GoldBuyerProduct
    @Published private(set) var sellDisplayPrices: [GoldBuyerProduct: String] = [:]

    /// Loading state
    @Published private(set) var isLoading: Bool = false

    /// Last update timestamp
    @Published private(set) var lastUpdateTime: Date?

    /// Error message if fetching failed
    @Published private(set) var error: String?

    private init() {}

    // MARK: - Public Methods

    /// Get price for a specific gold product
    /// - Parameter product: The gold buyer product
    /// - Returns: The price in VND, or nil if not available
    func getPrice(for product: GoldBuyerProduct) -> Double? {
        return prices[product]
    }

    /// Get formatted sell price display for a specific gold product
    /// - Parameter product: The gold buyer product
    /// - Returns: The formatted price string without commas, or nil if not available
    func getSellDisplayPrice(for product: GoldBuyerProduct) -> String? {
        return sellDisplayPrices[product]
    }

    /// Fetch all gold buyer product prices
    /// - Parameter forceRefresh: If true, will refresh even if data exists
    func fetchAllPrices(forceRefresh: Bool = false) async {
        // Skip if already loading or if data exists and not forcing refresh
        if isLoading || (!forceRefresh && !prices.isEmpty) {
            return
        }

        isLoading = true
        error = nil

        var newPrices: [GoldBuyerProduct: Double] = [:]
        var newSellDisplayPrices: [GoldBuyerProduct: String] = [:]

        // Fetch prices for all gold buyer products
        for product in GoldBuyerProduct.allCases {
            do {
                let request = GoldPriceRequest(
                    product: product.rawValue,
                    city: product.city,
                    lang: "vi",
                    branch: product.branch
                )

                let response = try await DashboardService.shared.fetchGoldPrice(request: request)

                if let data = response.data {
                    // Decrypt and parse the sell price
                    let sellPriceString = ApiDecryptor.decrypt(data.sellDisplay)
                        .replacingOccurrences(of: ",", with: "")

                    if let sellPrice = Double(sellPriceString) {
                        newPrices[product] = sellPrice
                        newSellDisplayPrices[product] = sellPriceString
                    }
                }
            } catch {
                print("Error fetching price for \(product.rawValue): \(error)")
                // Continue fetching other products even if one fails
            }
        }

        // Update published properties
        await MainActor.run {
            self.prices = newPrices
            self.sellDisplayPrices = newSellDisplayPrices
            self.lastUpdateTime = Date()
            self.isLoading = false

            if newPrices.isEmpty {
                self.error = "Không thể tải giá vàng"
            }
        }
    }

    /// Refresh all prices
    func refreshPrices() async {
        await fetchAllPrices(forceRefresh: true)
    }

    /// Check if prices are available
    var hasPrices: Bool {
        return !prices.isEmpty
    }

    /// Get all available prices as a dictionary
    func getAllPrices() -> [GoldBuyerProduct: Double] {
        return prices
    }
}
