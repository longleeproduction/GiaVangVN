//
//  GoldCalculatorViewModel.swift
//  GiaVangVN
//
//  Created by L7 Mobile on 22/10/25.
//

import Foundation
import Combine

// MARK: - View Models
class GoldCalculatorViewModel: ObservableObject {
    @Published var selectedGoldType = GoldType(name: "24K Gold", purity: "99%", karat: "24K")
    @Published var weight: String = "1"
    @Published var selectedUnit: WeightUnit = .gram
    @Published var pricePerGram: Double = 2_878_165.50 // VND per gram
    
    var quickWeights: [Int] = [1, 5, 10, 20, 50, 100, 250, 500]
    
    var weightInGrams: Double {
        let weightValue = Double(weight) ?? 0
        return selectedUnit.toGrams(weightValue)
    }
    
    var totalPrice: Double {
        return weightInGrams * pricePerGram
    }
    
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 2
        return "đ" + (formatter.string(from: NSNumber(value: totalPrice)) ?? "0")
    }
}

