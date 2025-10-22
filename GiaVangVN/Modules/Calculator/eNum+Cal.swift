//
//  eNum+Cal.swift
//  GiaVangVN
//
//  Created by L7 Mobile on 22/10/25.
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

