//
//  CurrencyDailyResponse.swift
//  GiaVangVN
//
//  Created by Claude Code
//

import Foundation

struct CurrencyDailyResponse: Codable {
    let success: Bool
    let data: CurrencyDailyData?

    struct CurrencyDailyData: Codable {
        let dateUpdate: String
        let lastUpdate: String
        let unit: String
        let list: [CurrencyDailyItem]

        enum CodingKeys: String, CodingKey {
            case dateUpdate = "date_update"
            case lastUpdate = "last_update"
            case unit
            case list
        }
    }

    struct CurrencyDailyItem: Codable, Identifiable {
        var id: String { code }

        let name: String
        let code: String
        let buy: String
        let buyDisplay: String
        let buyLast: String
        let buyLastDisplay: String
        let buyDelta: String
        let buyPercent: String
        let sell: String
        let sellDisplay: String
        let sellLast: String
        let sellLastDisplay: String
        let sellDelta: String
        let sellPercent: String
        let transfer: String
        let transferDisplay: String
        let transferLast: String
        let transferLastDisplay: String
        let transferDelta: String
        let transferPercent: String
        let dateUpdate: String
        let lastUpdate: String

        enum CodingKeys: String, CodingKey {
            case name
            case code
            case buy
            case buyDisplay = "buy_display"
            case buyLast = "buy_last"
            case buyLastDisplay = "buy_last_display"
            case buyDelta = "buy_delta"
            case buyPercent = "buy_percent"
            case sell
            case sellDisplay = "sell_display"
            case sellLast = "sell_last"
            case sellLastDisplay = "sell_last_display"
            case sellDelta = "sell_delta"
            case sellPercent = "sell_percent"
            case transfer
            case transferDisplay = "transfer_display"
            case transferLast = "transfer_last"
            case transferLastDisplay = "transfer_last_display"
            case transferDelta = "transfer_delta"
            case transferPercent = "transfer_percent"
            case dateUpdate = "date_update"
            case lastUpdate = "last_update"
        }
    }
}
