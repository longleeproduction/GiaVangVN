//
//  eNum+Cal.swift
//  GiaVangVN
//
//  Created by ORL on 22/10/25.
//

import SwiftUI

// MARK: - Models
struct GoldType {
    let name: String
    let purity: String
    let karat: String
}

enum WeightUnit: String, CaseIterable {
    case gram = "g"
    case ounce = "oz"
    case tola = "tola"
    case mithqal = "mithqal"

    var displayName: String {
        switch self {
        case .gram: return "Gram"
        case .ounce: return "Ounce"
        case .tola: return "Tola"
        case .mithqal: return "Mithqal"
        }
    }

    var description: String {
        switch self {
        case .gram: return "Standard metric unit"
        case .ounce: return "Troy ounce (31.1g)"
        case .tola: return "Traditional South Asian unit"
        case .mithqal: return "Traditional Middle Eastern unit"
        }
    }

    var icon: String {
        switch self {
        case .gram: return "scalemass"
        case .ounce: return "scalemass.fill"
        case .tola: return "diamond"
        case .mithqal: return "diamond.fill"
        }
    }

    var color: Color {
        switch self {
        case .gram: return .blue
        case .ounce: return .green
        case .tola: return .orange
        case .mithqal: return .purple
        }
    }

    // Convert to grams
    func toGrams(_ value: Double) -> Double {
        switch self {
        case .gram: return value
        case .ounce: return value * 31.1035
        case .tola: return value * 11.6638
        case .mithqal: return value * 4.25
        }
    }

    // Convert from grams
    func fromGrams(_ grams: Double) -> Double {
        switch self {
        case .gram: return grams
        case .ounce: return grams / 31.1035
        case .tola: return grams / 11.6638
        case .mithqal: return grams / 4.25
        }
    }
}

// MARK: - Currency Models
struct Currency: Identifiable, Equatable {
    let id = UUID()
    let code: String
    let name: String
    let symbol: String
    let flag: String

    static func == (lhs: Currency, rhs: Currency) -> Bool {
        return lhs.code == rhs.code
    }
}

// Popular currencies for calculator
extension Currency {
    static let usd = Currency(code: "USD", name: "US Dollar", symbol: "$", flag: "🇺🇸")
    static let vnd = Currency(code: "VND", name: "Vietnamese Dong", symbol: "₫", flag: "🇻🇳")
    static let eur = Currency(code: "EUR", name: "Euro", symbol: "€", flag: "🇪🇺")
    static let jpy = Currency(code: "JPY", name: "Japanese Yen", symbol: "¥", flag: "🇯🇵")
    static let gbp = Currency(code: "GBP", name: "British Pound", symbol: "£", flag: "🇬🇧")
    static let aud = Currency(code: "AUD", name: "Australian Dollar", symbol: "A$", flag: "🇦🇺")
    static let cad = Currency(code: "CAD", name: "Canadian Dollar", symbol: "C$", flag: "🇨🇦")
    static let chf = Currency(code: "CHF", name: "Swiss Franc", symbol: "Fr", flag: "🇨🇭")
    static let cny = Currency(code: "CNY", name: "Chinese Yuan", symbol: "¥", flag: "🇨🇳")
    static let sgd = Currency(code: "SGD", name: "Singapore Dollar", symbol: "S$", flag: "🇸🇬")
    static let thb = Currency(code: "THB", name: "Thai Baht", symbol: "฿", flag: "🇹🇭")
    static let krw = Currency(code: "KRW", name: "Korean Won", symbol: "₩", flag: "🇰🇷")
    static let hkd = Currency(code: "HKD", name: "Hong Kong Dollar", symbol: "HK$", flag: "🇭🇰")

    static let allCurrencies: [Currency] = [
        .usd, .vnd, .eur, .jpy, .gbp, .aud, .cad,
        .chf, .cny, .sgd, .thb, .krw, .hkd
    ]
}

