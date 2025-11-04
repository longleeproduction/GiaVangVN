//
//  GoldCalculatorViewModel.swift
//  GiaVangVN
//
//  Created by ORL on 22/10/25.
//

import Foundation
import Combine

// MARK: - View Models
class GoldCalculatorViewModel: ObservableObject {
    @Published var selectedGoldProduct: GoldBuyerProduct = .VangMiengSJC
    @Published var weight: String = "1"
    @Published var selectedUnit: WeightUnit = .chi

    var priceManager: GoldPriceManager

    var quickWeights: [Int] = [1, 5, 10, 20, 50, 100, 250, 500]

    init(priceManager: GoldPriceManager = GoldPriceManager.shared) {
        self.priceManager = priceManager
    }

    var weightInGrams: Double {
        let weightValue = Double(weight) ?? 0
        return selectedUnit.toGrams(weightValue)
    }

    var pricePerGram: Double {
        guard let price = priceManager.getPrice(for: selectedGoldProduct) else {
            return 0
        }
        // Price from API is per "chỉ" (3.75 grams), convert to per gram
        return price / 3.75
    }

    var totalPrice: Double {
        return weightInGrams * pricePerGram
    }

    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 0
        return "đ" + (formatter.string(from: NSNumber(value: totalPrice)) ?? "0")
    }

    var formattedPricePerGram: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 0
        return "đ" + (formatter.string(from: NSNumber(value: pricePerGram)) ?? "0")
    }
}

