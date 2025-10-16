//
//  CurrencyPriceResponse.swift
//  GiaVangVN
//
//  Created by Claude Code
//

import Foundation

struct CurrencyPriceResponse: Codable {
    let success: Bool
    let data: CurrencyPriceData?
}

struct CurrencyPriceData: Codable, Identifiable {
    let id: String
    let title: String
    let branch: String
    let code: String
    let dateUpdate: String
    let buyDisplay: String
    let buyDelta: String
    let buyPercent: String
    let sellDisplay: String
    let sellDelta: String
    let sellPercent: String
    let transferDisplay: String
    let transferDelta: String
    let transferPercent: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case branch
        case code
        case dateUpdate = "date_update"
        case buyDisplay = "buy_display"
        case buyDelta = "buy_delta"
        case buyPercent = "buy_percent"
        case sellDisplay = "sell_display"
        case sellDelta = "sell_delta"
        case sellPercent = "sell_percent"
        case transferDisplay = "transfer_display"
        case transferDelta = "transfer_delta"
        case transferPercent = "transfer_percent"
    }
}
