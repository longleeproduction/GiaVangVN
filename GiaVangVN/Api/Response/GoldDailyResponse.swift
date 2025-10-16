//
//  GoldDailyResponse.swift
//  GiaVangVN
//
//  Created by Claude Code
//

import Foundation

struct GoldDailyResponse: Codable {
    let success: Bool
    let data: GoldDailyData?

    struct GoldDailyData: Codable {
        let dateUpdate: String
        let lastUpdate: String
        let unit: String
        let cities: [GoldDailyCity]

        enum CodingKeys: String, CodingKey {
            case dateUpdate = "date_update"
            case lastUpdate = "last_update"
            case unit
            case cities
        }
    }

    struct GoldDailyCity: Codable, Identifiable {
        var id: String { city }

        let city: String
        let list: [GoldDailyItem]
    }

    struct GoldDailyItem: Codable, Identifiable {
        var id: String { name }

        let name: String
        let sell: String
        let sellDisplay: String
        let sellLast: String
        let sellLastDisplay: String
        let sellDelta: String
        let sellPercent: String
        let buy: String
        let buyDisplay: String
        let buyLast: String
        let buyLastDisplay: String
        let buyDelta: String
        let buyPercent: String

        enum CodingKeys: String, CodingKey {
            case name
            case sell
            case sellDisplay = "sell_display"
            case sellLast = "sell_last"
            case sellLastDisplay = "sell_last_display"
            case sellDelta = "sell_delta"
            case sellPercent = "sell_percent"
            case buy
            case buyDisplay = "buy_display"
            case buyLast = "buy_last"
            case buyLastDisplay = "buy_last_display"
            case buyDelta = "buy_delta"
            case buyPercent = "buy_percent"
        }
    }
}
