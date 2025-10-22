//
//  CurrencyCalculatorViewModel.swift
//  GiaVangVN
//
//  Created by L7 Mobile on 22/10/25.
//

import Foundation
import Combine

// MARK: - Currency Calculator View Model
class CurrencyCalculatorViewModel: ObservableObject {
    @Published var fromCurrency: Currency = .usd
    @Published var toCurrency: Currency = .vnd
    @Published var amount: String = "1"
    @Published var exchangeRate: Double = 25_000.0 // USD to VND default rate

    // Quick amount buttons
    var quickAmounts: [Int] = [10, 50, 100, 500, 1000, 5000, 10000, 50000]

    // Computed properties
    var amountValue: Double {
        return Double(amount) ?? 0
    }

    var convertedAmount: Double {
        return amountValue * exchangeRate
    }

    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amountValue)) ?? "0"
    }

    var formattedConvertedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: convertedAmount)) ?? "0"
    }

    var formattedExchangeRate: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 4
        return formatter.string(from: NSNumber(value: exchangeRate)) ?? "0"
    }

    // Swap currencies
    func swapCurrencies() {
        let temp = fromCurrency
        fromCurrency = toCurrency
        toCurrency = temp

        // Recalculate exchange rate (inverse)
        if exchangeRate != 0 {
            exchangeRate = 1.0 / exchangeRate
        }
    }

    // Update exchange rate based on currency pair
    func updateExchangeRate() {
        // Default exchange rates (these would ideally come from an API)
        exchangeRate = getExchangeRate(from: fromCurrency.code, to: toCurrency.code)
    }

    // Get exchange rate for currency pair
    private func getExchangeRate(from: String, to: String) -> Double {
        // Sample exchange rates (VND as base)
        let rates: [String: Double] = [
            "USD-VND": 25_000.0,
            "EUR-VND": 27_000.0,
            "JPY-VND": 168.0,
            "GBP-VND": 31_500.0,
            "AUD-VND": 16_200.0,
            "CAD-VND": 18_200.0,
            "CHF-VND": 28_500.0,
            "CNY-VND": 3_450.0,
            "SGD-VND": 18_600.0,
            "THB-VND": 710.0,
            "KRW-VND": 18.5,
            "HKD-VND": 3_200.0,
            "VND-USD": 1.0 / 25_000.0,
            "VND-EUR": 1.0 / 27_000.0,
            "VND-JPY": 1.0 / 168.0,
            "VND-GBP": 1.0 / 31_500.0,
            "VND-AUD": 1.0 / 16_200.0,
            "VND-CAD": 1.0 / 18_200.0,
            "VND-CHF": 1.0 / 28_500.0,
            "VND-CNY": 1.0 / 3_450.0,
            "VND-SGD": 1.0 / 18_600.0,
            "VND-THB": 1.0 / 710.0,
            "VND-KRW": 1.0 / 18.5,
            "VND-HKD": 1.0 / 3_200.0
        ]

        let pair = "\(from)-\(to)"

        // If same currency, rate is 1
        if from == to {
            return 1.0
        }

        // Check if we have a direct rate
        if let rate = rates[pair] {
            return rate
        }

        // If not, try to calculate through VND
        if from != "VND" && to != "VND" {
            let fromToVND = rates["\(from)-VND"] ?? 1.0
            let vndToTo = rates["VND-\(to)"] ?? 1.0
            return fromToVND * vndToTo
        }

        return 1.0
    }
}
